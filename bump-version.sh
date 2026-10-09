#!/usr/bin/env bash
# bump-version.sh
# Updates the TornadoVM release version used by the supported NVIDIA images.
#
# Usage:
#   ./bump-version.sh <new-version>
#   ./bump-version.sh 7.2.0
#
# What it updates:
#   - build.sh                                        (TORNADOVM_VERSION default)
#   - dockerFiles/Dockerfile.nvidia.{cuda,opencl}.{jdk21,jdk22plus}   (ARG TORNADO_TAG default)
#   - example/pom.xml                                 (tornado-api / tornado-matrices, X.Y.Z-jdk21)
#   - README.md                                       (image tag examples)
#
# NOT touched by this script (deliberately): the DEPRECATED images — build.sh's
# TAG_VERSION / TAG_VERSION_JDK22PLUS, push.sh, push-intel.sh, the source-built
# Dockerfile.nvidia.jdk21 / *.graalvm.* / *.oneapi.* Dockerfiles and
# polyglotImages/** (frozen at v5.2.0-jdk21). See README.md.
#
# Note: example/target/example-1.0-SNAPSHOT.jar is not rebuilt here; the GitHub workflow
# rebuilds it with Maven after running this script.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── helpers ──────────────────────────────────────────────────────────────────

current_version() {
    sed -n 's/^TORNADOVM_VERSION="${TORNADOVM_VERSION:-\([^}]*\)}"$/\1/p' build.sh
}

usage() {
    echo "Usage: $0 <new-version>"
    echo ""
    echo "  new-version   TornadoVM release version X.Y.Z, e.g. 7.2.0"
    echo ""
    echo "Current version detected from build.sh: $(current_version)"
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

if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    die "Version must be a bare release version X.Y.Z (e.g. 7.2.0), got: $NEW_VERSION"
fi

CURRENT_VERSION=$(current_version)
[[ -z "$CURRENT_VERSION" ]] && die "Could not detect current version from build.sh"

if [[ "$CURRENT_VERSION" == "$NEW_VERSION" ]]; then
    echo "Already at version $NEW_VERSION — nothing to do."
    exit 0
fi

echo "Bumping: $CURRENT_VERSION  →  $NEW_VERSION"
echo ""

# ── build.sh ─────────────────────────────────────────────────────────────────

replace_in_file "build.sh" "TORNADOVM_VERSION:-${CURRENT_VERSION}}" "TORNADOVM_VERSION:-${NEW_VERSION}}"
replace_in_file "build.sh" "TORNADOVM_VERSION=${CURRENT_VERSION} " "TORNADOVM_VERSION=${NEW_VERSION} "

# ── Dockerfiles ───────────────────────────────────────────────────────────────

DOCKERFILES=(
    dockerFiles/Dockerfile.nvidia.cuda.jdk21
    dockerFiles/Dockerfile.nvidia.cuda.jdk22plus
    dockerFiles/Dockerfile.nvidia.opencl.jdk21
    dockerFiles/Dockerfile.nvidia.opencl.jdk22plus
)

for f in "${DOCKERFILES[@]}"; do
    replace_in_file "$f" "ARG TORNADO_TAG=v${CURRENT_VERSION}" "ARG TORNADO_TAG=v${NEW_VERSION}"
done

# ── example/pom.xml ───────────────────────────────────────────────────────────
# Only touch the tornado-api and tornado-matrices <version> blocks.

POM="example/pom.xml"
if grep -q "<version>${CURRENT_VERSION}-jdk21</version>" "$POM"; then
    for artifact in tornado-api tornado-matrices; do
        sed -i "/<artifactId>${artifact}<\/artifactId>/{
            n
            s|<version>${CURRENT_VERSION}-jdk21</version>|<version>${NEW_VERSION}-jdk21</version>|
        }" "$POM"
    done
    echo "  [updated] $POM"
else
    echo "  [skip]    $POM  (pattern not found)"
fi

# ── README.md ─────────────────────────────────────────────────────────────────

replace_in_file "README.md" "\`${CURRENT_VERSION}\`" "\`${NEW_VERSION}\`"
replace_in_file "README.md" "TORNADOVM_VERSION=${CURRENT_VERSION} " "TORNADOVM_VERSION=${NEW_VERSION} "

# ── done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done. Supported images now target TornadoVM v$NEW_VERSION."
echo ""
echo "Next steps:"
echo "  Rebuild the example :  (cd example && mvn clean package)"
echo "  Build an image      :  ./build.sh --nvidia-cuda-jdk25"
echo "  Or run the 'Build, Test & Push Docker Images' GitHub workflow with version v$NEW_VERSION."
