#!/usr/bin/env bash
# bump-version.sh
# One-click script to update the TornadoVM version across all files.
#
# Usage:
#   ./bump-version.sh <new-version>
#   ./bump-version.sh 2.2.0
#
# What it updates:
#   - build.sh                                        (TAG_VERSION=)
#   - push.sh                                         (tag=)
#   - push-intel.sh                                   (tag=)
#   - polyglotImages/buildDocker.sh                   (TAG_VERSION=)
#   - dockerFiles/Dockerfile.*                        (git checkout tags/v)
#   - polyglotImages/**/Dockerfile.*                  (git checkout tags/v)
#   - example/pom.xml                                 (tornado-api / tornado-matrices versions)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── helpers ──────────────────────────────────────────────────────────────────

usage() {
    echo "Usage: $0 <new-version>"
    echo ""
    echo "  new-version   SemVer string, e.g. 2.2.0"
    echo ""
    echo "Current version detected from build.sh: $(grep 'TAG_VERSION=' build.sh | head -1 | cut -d'=' -f2)"
    exit 1
}

die() { echo "ERROR: $*" >&2; exit 1; }

replace_in_file() {
    local file="$1" old="$2" new="$3"
    if grep -qF "$old" "$file"; then
        sed -i "s|${old}|${new}|g" "$file"
        echo "  [updated] $file"
    else
        echo "  [skip]    $file  (pattern not found)"
    fi
}

# ── validate args ─────────────────────────────────────────────────────────────

[[ $# -lt 1 ]] && usage

NEW_VERSION="$1"

# Validate semver-ish (digits and dots only)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    die "Version must be in X.Y.Z format (e.g. 2.2.0), got: $NEW_VERSION"
fi

# Auto-detect current version from build.sh
CURRENT_VERSION=$(grep 'TAG_VERSION=' build.sh | head -1 | cut -d'=' -f2 | tr -d '[:space:]')
[[ -z "$CURRENT_VERSION" ]] && die "Could not detect current version from build.sh"

if [[ "$CURRENT_VERSION" == "$NEW_VERSION" ]]; then
    echo "Already at version $NEW_VERSION — nothing to do."
    exit 0
fi

echo "Bumping: $CURRENT_VERSION  →  $NEW_VERSION"
echo ""

# ── build / push scripts ──────────────────────────────────────────────────────

replace_in_file "build.sh"                     "TAG_VERSION=${CURRENT_VERSION}" "TAG_VERSION=${NEW_VERSION}"
replace_in_file "push.sh"                      "tag=${CURRENT_VERSION}"         "tag=${NEW_VERSION}"
replace_in_file "push-intel.sh"                "tag=${CURRENT_VERSION}"         "tag=${NEW_VERSION}"
replace_in_file "polyglotImages/buildDocker.sh" "TAG_VERSION=${CURRENT_VERSION}" "TAG_VERSION=${NEW_VERSION}"

# ── Dockerfiles ───────────────────────────────────────────────────────────────

DOCKERFILES=(
    dockerFiles/Dockerfile.nvidia.jdk21
    dockerFiles/Dockerfile.nvidia.graalvm.jdk21
    dockerFiles/Dockerfile.nvidia.graalvm.ptx.jdk17
    dockerFiles/Dockerfile.oneapi.intel.jdk21
    dockerFiles/Dockerfile.oneapi.intel.graalvm.jdk21
    polyglotImages/polyglot-graalpy/Dockerfile.intel.oneapi.graalpy.jdk21
    polyglotImages/polyglot-graalpy/Dockerfile.nvidia.opencl.graalpy.jdk21
    polyglotImages/polyglot-graaljs/Dockerfile.nvidia.opencl.graaljs.jdk21
    polyglotImages/polyglot-truffleruby/Dockerfile.nvidia.opencl.truffleruby.jdk21
)

for f in "${DOCKERFILES[@]}"; do
    replace_in_file "$f" "checkout tags/v${CURRENT_VERSION}" "checkout tags/v${NEW_VERSION}"
done

# ── example/pom.xml ───────────────────────────────────────────────────────────
# Only touch the tornado-api and tornado-matrices <version> blocks.

POM="example/pom.xml"
if grep -q "<version>${CURRENT_VERSION}</version>" "$POM"; then
    # Multi-line sed: for each TornadoVM artifact, replace the following <version> line.
    for artifact in tornado-api tornado-matrices; do
        sed -i "/<artifactId>${artifact}<\/artifactId>/{
            n
            s|<version>${CURRENT_VERSION}</version>|<version>${NEW_VERSION}</version>|
        }" "$POM"
    done
    echo "  [updated] $POM"
else
    echo "  [skip]    $POM  (pattern not found)"
fi

# ── done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. All files updated to $NEW_VERSION."
echo ""
echo "Next steps:"
echo "  Build all images  :  ./buildAll.sh intel   OR   ./buildAll.sh nvidia"
echo "  Push all images   :  ./push.sh"
echo "  Push Intel only   :  ./push-intel.sh"
