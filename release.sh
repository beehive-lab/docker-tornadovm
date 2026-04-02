#!/usr/bin/env bash
# release.sh
# Bump version, build Docker images, and push — all in one shot.
#
# Usage:
#   ./release.sh <new-version> <platform>
#
# Platform options:
#   all      – build & push nvidia + intel images
#   nvidia   – build & push nvidia images only
#   intel    – build & push intel images only
#
# Examples:
#   ./release.sh 2.2.0 all
#   ./release.sh 2.2.0 nvidia
#   ./release.sh 2.2.0 intel

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── usage ─────────────────────────────────────────────────────────────────────

usage() {
    echo "Usage: $0 <new-version> <platform>"
    echo ""
    echo "  new-version   SemVer string, e.g. 2.2.0"
    echo "  platform      all | nvidia | intel"
    echo ""
    echo "Current version: $(grep 'TAG_VERSION=' build.sh | head -1 | cut -d'=' -f2)"
    exit 1
}

[[ $# -lt 2 ]] && usage

NEW_VERSION="$1"
PLATFORM="$2"

case "$PLATFORM" in
    all|nvidia|intel) ;;
    *) echo "ERROR: platform must be all, nvidia, or intel" >&2; usage ;;
esac

# ── step 1 — bump version ──────────────────────────────────────────────────────

echo "════════════════════════════════════════"
echo " Step 1/3 — Bump version to $NEW_VERSION"
echo "════════════════════════════════════════"
bash bump-version.sh "$NEW_VERSION"

# ── step 2 — build ────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════"
echo " Step 2/3 — Build ($PLATFORM)"
echo "════════════════════════════════════════"

if [[ "$PLATFORM" == "nvidia" || "$PLATFORM" == "all" ]]; then
    bash build.sh --nvidia-jdk21
    bash build.sh --nvidia-graalVM-JDK21
fi

if [[ "$PLATFORM" == "intel" || "$PLATFORM" == "all" ]]; then
    bash build.sh --intel-jdk21
    bash build.sh --intel-graalVM-JDK21
fi

# ── step 3 — push ─────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════"
echo " Step 3/3 — Push ($PLATFORM)"
echo "════════════════════════════════════════"

if [[ "$PLATFORM" == "all" ]]; then
    bash push.sh
elif [[ "$PLATFORM" == "nvidia" ]]; then
    tag="$NEW_VERSION"
    docker push beehivelab/tornadovm-nvidia-openjdk:"$tag"
    docker push beehivelab/tornadovm-nvidia-openjdk:latest
    docker push beehivelab/tornadovm-nvidia-graalvm:"$tag"
    docker push beehivelab/tornadovm-nvidia-graalvm:latest
elif [[ "$PLATFORM" == "intel" ]]; then
    bash push-intel.sh
fi

# ── done ──────────────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════"
echo " Released TornadoVM $NEW_VERSION ($PLATFORM)"
echo "════════════════════════════════════════"
