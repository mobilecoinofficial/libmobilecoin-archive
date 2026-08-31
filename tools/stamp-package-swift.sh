#!/usr/bin/env bash
# Copy VERSION and XCFRAMEWORK_SHA256 from release.env into the two literals in
# Package.swift. A manifest cannot read release.env at resolve time, so the
# values are pushed in here instead.
#
# --check verifies they already agree. CI runs that, so a release.env bump that
# forgets Package.swift is caught before it ships an unresolvable manifest.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$REPO_ROOT/release.env"
MANIFEST="$REPO_ROOT/Package.swift"

CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

[ -f "$ENV_FILE" ] || { echo "error: missing $ENV_FILE" >&2; exit 1; }
[ -f "$MANIFEST" ] || { echo "error: missing $MANIFEST" >&2; exit 1; }

# shellcheck disable=SC1090
. "$ENV_FILE"
: "${VERSION:?release.env has no VERSION}"
: "${XCFRAMEWORK_SHA256:?release.env has no XCFRAMEWORK_SHA256}"

[[ "$XCFRAMEWORK_SHA256" =~ ^[0-9a-f]{64}$ ]] || {
    echo "error: XCFRAMEWORK_SHA256 is not a 64-character sha256: $XCFRAMEWORK_SHA256" >&2
    exit 1
}

# The value between the quotes on `let <name> = "..."`.
current_literal() {
    sed -n "s/^let $1 = \"\\(.*\\)\"\$/\\1/p" "$MANIFEST"
}

CUR_VERSION="$(current_literal version)"
CUR_CHECKSUM="$(current_literal xcframeworkChecksum)"

[ -n "$CUR_VERSION" ] || { echo "error: no 'let version = \"...\"' in $MANIFEST" >&2; exit 1; }
[ -n "$CUR_CHECKSUM" ] || { echo "error: no 'let xcframeworkChecksum = \"...\"' in $MANIFEST" >&2; exit 1; }

if [ "$CHECK" = 1 ]; then
    rc=0
    [ "$CUR_VERSION" = "$VERSION" ] || {
        echo "Package.swift version is $CUR_VERSION, release.env says $VERSION" >&2; rc=1; }
    [ "$CUR_CHECKSUM" = "$XCFRAMEWORK_SHA256" ] || {
        echo "Package.swift checksum is $CUR_CHECKSUM, release.env says $XCFRAMEWORK_SHA256" >&2; rc=1; }
    [ "$rc" = 0 ] || { echo "run: make stamp-manifest" >&2; exit 1; }
    echo "Package.swift agrees with release.env (v$VERSION)"
    exit 0
fi

# Anchored on the let bindings at column 0, so no other line carrying the same
# string is rewritten.
sed -i '' \
    -e "s|^let version = \".*\"\$|let version = \"$VERSION\"|" \
    -e "s|^let xcframeworkChecksum = \".*\"\$|let xcframeworkChecksum = \"$XCFRAMEWORK_SHA256\"|" \
    "$MANIFEST"

"$0" --check
