#!/usr/bin/env bash
# Build a reproducible zip of LibMobileCoinLibrary.xcframework and print its
# SwiftPM checksum. Reproducible means the same input tree always yields the
# same checksum, so Package.swift can carry it before the asset is uploaded.
set -euo pipefail

usage() {
    echo "usage: $0 <path-to-xcframework> <output-zip>" >&2
    exit 2
}

[ "$#" -eq 2 ] || usage

XCFRAMEWORK="${1%/}"
OUTPUT="$2"

[ -d "$XCFRAMEWORK" ] || { echo "error: no such xcframework: $XCFRAMEWORK" >&2; exit 1; }

FRAMEWORK_NAME="$(basename "$XCFRAMEWORK")"
case "$FRAMEWORK_NAME" in
    *.xcframework) ;;
    *) echo "error: $XCFRAMEWORK is not an .xcframework" >&2; exit 1 ;;
esac

# SwiftPM requires the .xcframework at the root of the archive, so stage a copy
# and zip from the staging directory.
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
cp -R "$XCFRAMEWORK" "$STAGING/$FRAMEWORK_NAME"

# Normalize every attribute the zip records. Mode, mtime and entry order are the
# three inputs that otherwise make two zips of one tree differ.
find "$STAGING" -type d -exec chmod 755 {} +
find "$STAGING" -type f -exec chmod 644 {} +
find "$STAGING" -exec touch -t 198001010000 {} +

# mkdir -p before the cd: on a clean checkout .build does not exist yet, and
# `cd` to a missing directory would leave OUTPUT_ABS rooted at /.
mkdir -p "$(dirname "$OUTPUT")"
rm -f "$OUTPUT"
OUTPUT_ABS="$(cd "$(dirname "$OUTPUT")" && pwd)/$(basename "$OUTPUT")"

# -X drops uid/gid and the extra attribute field. -D drops directory entries.
# The sorted file list fixes entry order.
(
    cd "$STAGING"
    find "$FRAMEWORK_NAME" -type f | LC_ALL=C sort | zip -q -X -D -o "$OUTPUT_ABS" -@
)

if command -v swift >/dev/null 2>&1; then
    CHECKSUM="$(swift package compute-checksum "$OUTPUT_ABS")"
else
    CHECKSUM="$(shasum -a 256 "$OUTPUT_ABS" | cut -d' ' -f1)"
fi

echo "$CHECKSUM"
