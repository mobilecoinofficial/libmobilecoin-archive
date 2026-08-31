# Copyright (c) 2018-2022 The MobileCoin Foundation

####################################
######### Public Variables #########
####################################

### Project Environment Variables

# Goto cargo command
#export SGX_MODE ?= SW
export SGX_MODE ?= HW
export IAS_MODE ?= PROD

### Build Configuration

CARGO_PROFILE ?= mobile-release
CARGO_BUILD_FLAGS ?=
CARGO_TARGET_DIR ?= ./target

$(info profile: $(CARGO_PROFILE))

### Toolchain

CARGO ?= cargo

####################################
######## Internal Variables ########
####################################

### Local Variables

DOT:= .
DASH:= -

CARGO_PACKAGE = libmobilecoin

ALL_ARCHS_IOS = aarch64-apple-ios-sim aarch64-apple-ios x86_64-apple-ios x86_64-apple-darwin aarch64-apple-darwin

# Matches the .iOS(.v13) floor in Package.swift and the podspec.
IOS_DEPLOYMENT_TARGET = 13.0

IOS_LIB = libmobilecoin.a
IOS_LIB_STRIPPED = libmobilecoin_stripped.a
IOS_C_HEADERS = include/*

### Helper Function

# First argument $(1) is a build-target, $(2) is the output directory
define BINARY_copy
	mkdir -p out/ios/$(2)/$(1)/${CARGO_PROFILE}
	cp $(CARGO_TARGET_DIR)/$(1)/${CARGO_PROFILE}/libmobilecoin.a out/ios/$(2)/$(1)/${CARGO_PROFILE};
endef

####################################
############## Targets #############
####################################

.PHONY: all
all: setup ios
	
CARGO_BUILD_FLAGS += --lib -Z avoid-dev-deps
ifeq ($(CARGO_PROFILE),release)
  BUILD_CONFIG_FOLDER = ${CARGO_PROFILE}
  CARGO_BUILD_FLAGS += --release
else ifeq ($(CARGO_PROFILE),debug)
  BUILD_CONFIG_FOLDER = debug
else
  BUILD_CONFIG_FOLDER = ${CARGO_PROFILE}
  CARGO_BUILD_FLAGS += -Z unstable-options --profile ${CARGO_PROFILE}
endif

LEGACY_CARGO_BUILD_FLAGS = $(CARGO_BUILD_FLAGS)

.PHONY: setup
setup:
	rustup target add x86_64-apple-ios aarch64-apple-ios aarch64-apple-darwin x86_64-apple-darwin
	rustup component add llvm-tools-preview rust-src
	rustup run --install stable cargo install cargo-binutils
	 ../tools/patch-cmake.sh


.PHONY: ios
ios: out/ios/target

# mbedtls-sys-auto configures the vendored mbedtls with CMake, whose CMakeLists
# declares a minimum below 3.5, and CMake 4 removed support for it. Set for
# every target, because the configure that fails is the host build.
CARGO_ENV_FLAGS += CMAKE_POLICY_VERSION_MINIMUM=3.5

.PHONY: $(ALL_ARCHS_IOS)
aarch64-apple-ios-sim aarch64-apple-ios x86_64-apple-ios: CARGO_ENV_FLAGS += IPHONEOS_DEPLOYMENT_TARGET="$(IOS_DEPLOYMENT_TARGET)"
# bindgen maps the Rust target to arm64-apple-ios-sim, which clang rejects
# because the environment is spelled -simulator. Hand it the real triple.
aarch64-apple-ios-sim: CARGO_ENV_FLAGS += BINDGEN_EXTRA_CLANG_ARGS_aarch64_apple_ios_sim="--target=arm64-apple-ios$(IOS_DEPLOYMENT_TARGET)-simulator"
x86_64-apple-darwin aarch64-apple-darwin: CARGO_ENV_FLAGS += MACOSX_DEPLOYMENT_TARGET="11.0"
x86_64-apple-ios x86_64-apple-darwin: LD_ARCH = x86_64
aarch64-apple-ios aarch64-apple-ios-sim aarch64-apple-darwin: LD_ARCH = arm64
x86_64-apple-ios-macabi aarch64-apple-ios-sim aarch64-apple-ios-macabi: LEGACY_CARGO_BUILD_FLAGS += -Zbuild-std
$(ALL_ARCHS_IOS):
	$(CARGO_ENV_FLAGS) $(CARGO) build --package $(CARGO_PACKAGE) --target $@ $(LEGACY_CARGO_BUILD_FLAGS)

	mkdir -p out/ios/target
	$(call BINARY_copy,$@,target)

	mkdir -p out/ios/include
	cp $(IOS_C_HEADERS) out/ios/include


.PHONY: out/ios/target
out/ios/target: $(ALL_ARCHS_IOS)
	mkdir -p out/ios/target
	$(foreach arch,$^,$(call BINARY_copy,$(arch),target))

	mkdir -p out/ios/include
	cp $(IOS_C_HEADERS) out/ios/include


.PHONY: clean
clean:
	@rm -r target 2>/dev/null || true

####################################
############# Commands #############
####################################

.PHONY: setup-dev
setup-dev:
	cargo install cbindgen

.PHONY: cbindgen
cbindgen:
	cbindgen --crate libmobilecoin -o libmobilecoin_cbindgen.h
