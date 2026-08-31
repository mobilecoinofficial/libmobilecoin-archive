MOBILECOIN_DIR = Vendor/mobilecoin
LIBMOBILECOIN_LIB_DIR = libmobilecoin
LIBMOBILECOIN_ARTIFACTS_DIR = $(LIBMOBILECOIN_LIB_DIR)/out/ios
LIBMOBILECOIN_ARTIFACTS_HEADERS = $(LIBMOBILECOIN_LIB_DIR)/out/ios/include
# Not .build/artifacts: SwiftPM extracts binary targets there, and
# clean-artifacts would delete them.
ARTIFACTS_DIR = .build/mc-artifacts
RELEASE_ZIP = .build/LibMobileCoinLibrary.xcframework.zip
GITHUB_REPO = mobilecoinofficial/libmobilecoin
TEST_VECTOR_DIR = Sources/TestVector
IOS_TARGETS = aarch64-apple-ios-sim aarch64-apple-ios x86_64-apple-ios x86_64-apple-darwin aarch64-apple-darwin

LIBMOBILECOIN_PROFILE = mobile-release

define BINARY_copy
	$(foreach arch,$(IOS_TARGETS),cp $(LIBMOBILECOIN_ARTIFACTS_DIR)/$(1)/$(arch)/$(LIBMOBILECOIN_PROFILE)/libmobilecoin.a $(ARTIFACTS_DIR)/target/$(arch)/release/libmobilecoin.a;)
endef

.PHONY: default
default: setup build clean-artifacts copy generate

# Vendor/mobilecoin is a build-time input this target fetches. Every target
# that reads it depends on this so a fresh clone builds without extra steps.
.PHONY: vendor
vendor:
	tools/fetch-vendor.sh

.PHONY: setup
setup: vendor
	cd "$(LIBMOBILECOIN_LIB_DIR)" && $(MAKE) setup
	bundle install

# Unexport conditional environment variables so the build is more predictable
unexport SGX_MODE
unexport IAS_MODE
unexport CARGO_BUILD_FLAGS
unexport CARGO_TARGET_DIR
unexport CARGO_PROFILE

.PHONY: build
build: vendor
	cd "$(LIBMOBILECOIN_LIB_DIR)" && $(MAKE)


.PHONY: clean-artifacts
clean-artifacts:
	rm -r "$(ARTIFACTS_DIR)" 2>/dev/null || true
	mkdir -p "$(ARTIFACTS_DIR)"

	# Create arch specific folders for each lib
	$(foreach arch,$(IOS_TARGETS),mkdir -p $(ARTIFACTS_DIR)/target/$(arch)/release;) 

.PHONY: copy
copy: copy-libs generate-xcframework

.PHONY: copy-libs
copy-libs:
	$(call BINARY_copy,target)
	cp -R "$(LIBMOBILECOIN_ARTIFACTS_HEADERS)" "$(ARTIFACTS_DIR)"

.PHONY: generate
generate: generate-test-vectors generate-protoc 

.PHONY: generate-protoc
generate-protoc: vendor
	rm -r Sources/Generated/Proto 2>/dev/null || true
	DOCKER_BUILDKIT=1 docker build . \
		--build-arg grpc_swift_version=1.0.0 \
		--output .

.PHONY: generate-test-vectors
generate-test-vectors: vendor
	rm -rf $(TEST_VECTOR_DIR)/vectors
	cp -R $(MOBILECOIN_DIR)/test-vectors/vectors $(TEST_VECTOR_DIR)
	cd $(TEST_VECTOR_DIR)/vectors && find . -type f -name '*.jsonl' -exec mv -fi '{}' ./ ';'
	cd $(TEST_VECTOR_DIR)/vectors && find .  -mindepth 1 -maxdepth 1 -type d -exec rm -rf '{}' ';'

.PHONY: generate-xcframework
generate-xcframework:
	rm -rf $(ARTIFACTS_DIR)/LibMobileCoinLibrary.xcframework || true
	rm libmobilecoin/out/ios/target/libmobilecoin_macos.a || true
	rm libmobilecoin/out/ios/target/libmobilecoin_iossimulator.a || true
	mkdir -p .build/headers
	cp $(ARTIFACTS_DIR)/include/* .build/headers
	cp modulemap/module.modulemap .build/headers
	mkdir -p libmobilecoin/out/ios/target
	lipo -create \
		$(ARTIFACTS_DIR)/target/x86_64-apple-darwin/release/libmobilecoin.a \
		$(ARTIFACTS_DIR)/target/aarch64-apple-darwin/release/libmobilecoin.a \
		-output $(LIBMOBILECOIN_ARTIFACTS_DIR)/target/libmobilecoin_macos.a
	lipo -create \
		$(ARTIFACTS_DIR)/target/x86_64-apple-ios/release/libmobilecoin.a \
		$(ARTIFACTS_DIR)/target/aarch64-apple-ios-sim/release/libmobilecoin.a \
		-output $(LIBMOBILECOIN_ARTIFACTS_DIR)/target/libmobilecoin_iossimulator.a
	rm -rf $(LIBMOBILECOIN_ARTIFACTS_DIR)/LibMobileCoinLibrary.xcframework
	xcodebuild -create-xcframework \
		-library $(LIBMOBILECOIN_ARTIFACTS_DIR)/target/libmobilecoin_macos.a \
		-headers .build/headers \
		-library $(LIBMOBILECOIN_ARTIFACTS_DIR)/target/libmobilecoin_iossimulator.a \
		-headers .build/headers \
		-library $(ARTIFACTS_DIR)/target/aarch64-apple-ios/release/libmobilecoin.a \
		-headers .build/headers \
		-output $(ARTIFACTS_DIR)/LibMobileCoinLibrary.xcframework
	rm -rf .build/headers


.PHONY: lint
lint: lint-podspec

.PHONY: lint-locally
lint-locally: lint-locally-podspec

.PHONY: publish
publish: package tag-release upload-release publish-podspec

.PHONY: publish-hotfix
publish-hotfix: tag-hotfix publish-podspec

.PHONY: push-generated
push-generated:
	git add Sources/GRPC
	git add Sources/HTTP
	git add Sources/Common
	if ! git diff-index --quiet HEAD; then \
		git commit -m '[skip ci] commit generated protos from build machine'; \
		git push origin HEAD; \
	fi

# Release

# Build the reproducible release zip and print its SwiftPM checksum. The
# checksum is what Package.swift and the podspec both pin.
.PHONY: package
package:
	tools/package-xcframework.sh \
		"$(ARTIFACTS_DIR)/LibMobileCoinLibrary.xcframework" "$(RELEASE_ZIP)"

# Attach the packaged zip to the release for the tag tag-release just pushed.
# Package.swift and the podspec both point a consumer at this exact URL, so
# until this runs neither of them resolves.
.PHONY: upload-release
upload-release:
	@set -eu; \
	[ -f "$(RELEASE_ZIP)" ] || \
		{ echo 'Error: $(RELEASE_ZIP) not found. Run `make package` first.'; exit 1; }; \
	VERSION="$$(bundle exec pod ipc spec LibMobileCoin.podspec | jq -r '.version')"; \
	if ! gh release view "v$$VERSION" --repo $(GITHUB_REPO) >/dev/null 2>&1; then \
		gh release create "v$$VERSION" --repo $(GITHUB_REPO) --title "v$$VERSION" --notes ""; \
	fi; \
	gh release upload "v$$VERSION" "$(RELEASE_ZIP)" --repo $(GITHUB_REPO) --clobber; \
	echo "uploaded $(RELEASE_ZIP) to v$$VERSION"

.PHONY: tag-release
tag-release:
	@[[ "$$(git rev-parse --abbrev-ref HEAD)" == "master" ]] || \
		{ echo 'Error: Must be on branch "master" when tagging a release.'; exit 1; }
	VERSION="$$(bundle exec pod ipc spec LibMobileCoin.podspec | jq -r '.version')" && \
		git tag "v$$VERSION" && \
		git push git@github.com:mobilecoinofficial/libmobilecoin.git "refs/tags/v$$VERSION"
	

.PHONY: tag-hotfix
tag-hotfix:
	VERSION="$$(bundle exec pod ipc spec LibMobileCoin.podspec | jq -r '.version')" && \
		git tag "v$$VERSION" && \
		git push git@github.com:mobilecoinofficial/libmobilecoin.git "refs/tags/v$$VERSION"

# LibMobileCoin pod

.PHONY: lint-locally-podspec
lint-locally-podspec:
	bundle exec pod lib lint LibMobileCoin.podspec --allow-warnings

.PHONY: lint-podspec
lint-podspec:
	bundle exec pod spec lint LibMobileCoin.podspec --allow-warnings

.PHONY: publish-podspec
publish-podspec:
	bundle exec pod trunk push LibMobileCoin.podspec --allow-warnings

.PHONY: clean
clean:
	$(MAKE) -C libmobilecoin clean
	@rm -r $(MOBILECOIN_DIR)/target 2>/dev/null || true

.PHONY: patch-cmake
patch-cmake:
	tools/patch-cmake.sh

.PHONY: unpatch-cmake
unpatch-cmake:
	tools/unpatch-cmake.sh

.PHONY: test-spm
test-spm:
	cd LibMobileCoinExample && swift package reset && swift test
