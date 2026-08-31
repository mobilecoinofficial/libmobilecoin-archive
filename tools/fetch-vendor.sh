#!/usr/bin/env bash
# Check out the pinned mobilecoinfoundation/mobilecoin revision into
# Vendor/mobilecoin. It is a build-time input only, so the build fetches it
# and no SwiftPM consumer carries the foundation monorepo in its checkout.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_DIR="$REPO_ROOT/Vendor/mobilecoin"
REV_FILE="$REPO_ROOT/Vendor/mobilecoin.rev"
REMOTE="${MOBILECOIN_REMOTE:-https://github.com/mobilecoinfoundation/mobilecoin.git}"

[ -f "$REV_FILE" ] || { echo "error: missing $REV_FILE" >&2; exit 1; }
REV="$(tr -d '[:space:]' < "$REV_FILE")"
[ -n "$REV" ] || { echo "error: $REV_FILE is empty" >&2; exit 1; }

# A full SHA, not a branch name. A branch would never equal the rev-parse output
# below, so the up-to-date fast path could never hit: every build would fetch,
# force-checkout, and silently re-pin to wherever the branch had moved.
if [[ ! "$REV" =~ ^[0-9a-f]{40}$ ]]; then
    echo "error: $REV_FILE must hold a full 40-character SHA, found: $REV" >&2
    exit 1
fi

# Serialize against another make process on the same checkout. Two concurrent
# runs would otherwise race the rm -rf below against an in-flight checkout and
# leave a half-populated tree with no error. mkdir is atomic on every filesystem
# we build on; flock is not on macOS.
LOCK_DIR="$REPO_ROOT/Vendor/.mobilecoin.lock"
# is_locked tracks OUR mkdir, so the loop below can tell "we hold the lock"
# from "somebody else does" and time out on the second.
is_locked=0
for attempt in $(seq 1 300); do
    if mkdir "$LOCK_DIR" 2>/dev/null; then
        # shellcheck disable=SC2064
        trap "rmdir \"$LOCK_DIR\" 2>/dev/null || true" EXIT INT TERM
        is_locked=1
        break
    fi
    [ "$attempt" = 1 ] && echo "waiting for $LOCK_DIR" >&2
    sleep 1
done
[ "$is_locked" = 1 ] || {
    echo "error: could not acquire $LOCK_DIR after 300s." >&2
    echo "       If no other build is running, remove it: rmdir $LOCK_DIR" >&2
    exit 1
}

# -e, not -d: in a submodule checkout .git is a FILE holding a gitdir pointer,
# and a developer may have symlinked this path at a shared foundation clone.
# Treating either as "not a git checkout" would drop us into the else branch,
# whose rm -rf destroys uncommitted work, or into a force-checkout that detaches
# somebody's shared clone.
if [ -e "$VENDOR_DIR/.git" ]; then
    if [ -L "$VENDOR_DIR" ]; then
        echo "error: $VENDOR_DIR is a symlink to $(readlink "$VENDOR_DIR")." >&2
        echo "       Refusing to force-checkout a tree this repo does not own." >&2
        echo "       Remove the symlink to let the build manage it." >&2
        exit 1
    fi
    if [ -f "$VENDOR_DIR/.git" ]; then
        echo "error: $VENDOR_DIR is still a git submodule checkout." >&2
        echo "       Vendor/mobilecoin is a plain fetched tree." >&2
        echo "       Migrate with:" >&2
        echo "         git submodule deinit -f Vendor/mobilecoin" >&2
        echo "         rm -rf .git/modules/Vendor/mobilecoin Vendor/mobilecoin" >&2
        echo "       Anything uncommitted in there is lost, so check it first." >&2
        exit 1
    fi
    # set-url so MOBILECOIN_REMOTE reaches an existing checkout; the add
    # covers a tree that has no origin yet.
    git -C "$VENDOR_DIR" remote set-url origin "$REMOTE" 2>/dev/null || \
        git -C "$VENDOR_DIR" remote add origin "$REMOTE"
    CURRENT="$(git -C "$VENDOR_DIR" rev-parse HEAD 2>/dev/null || echo none)"
    # --cached as well: plain `git diff` compares the worktree against the
    # index, so a staged edit to a tracked file reads as clean.
    if [ "$CURRENT" = "$REV" ] &&
       git -C "$VENDOR_DIR" diff --quiet &&
       git -C "$VENDOR_DIR" diff --cached --quiet; then
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
# Fetching a bare SHA needs uploadpack.allowAnySHA1InWant on the remote. GitHub
# has it on; a self-hosted mirror set through MOBILECOIN_REMOTE may not, and
# fails with "couldn't find remote ref <sha>".
git -C "$VENDOR_DIR" fetch -q --depth 1 origin "$REV"
git -C "$VENDOR_DIR" checkout -q --force FETCH_HEAD

echo "Vendor/mobilecoin checked out at $REV"
