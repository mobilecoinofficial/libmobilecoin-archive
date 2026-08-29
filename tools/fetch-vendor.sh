#!/usr/bin/env bash
# Check out the pinned mobilecoinfoundation/mobilecoin revision into
# Vendor/mobilecoin. This used to be a git submodule, which meant every SwiftPM
# consumer cloned the foundation monorepo on checkout. It is a build-time input
# only, so the build fetches it instead.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_DIR="$REPO_ROOT/Vendor/mobilecoin"
REV_FILE="$REPO_ROOT/Vendor/mobilecoin.rev"
REMOTE="${MOBILECOIN_REMOTE:-https://github.com/mobilecoinfoundation/mobilecoin.git}"

[ -f "$REV_FILE" ] || { echo "error: missing $REV_FILE" >&2; exit 1; }
REV="$(tr -d '[:space:]' < "$REV_FILE")"
[ -n "$REV" ] || { echo "error: $REV_FILE is empty" >&2; exit 1; }

if [ -d "$VENDOR_DIR/.git" ]; then
    CURRENT="$(git -C "$VENDOR_DIR" rev-parse HEAD 2>/dev/null || echo none)"
    if [ "$CURRENT" = "$REV" ] && git -C "$VENDOR_DIR" diff --quiet; then
        echo "Vendor/mobilecoin already at $REV"
        exit 0
    fi
else
    rm -rf "$VENDOR_DIR"
    mkdir -p "$VENDOR_DIR"
    git -C "$VENDOR_DIR" init -q
    git -C "$VENDOR_DIR" remote add origin "$REMOTE"
fi

# A single-revision fetch, so the 4GB of foundation history never lands here.
git -C "$VENDOR_DIR" fetch -q --depth 1 origin "$REV"
git -C "$VENDOR_DIR" checkout -q --force FETCH_HEAD
git -C "$VENDOR_DIR" submodule update --init --recursive --depth 1

echo "Vendor/mobilecoin checked out at $REV"
