#!/usr/bin/env bash
# update-descriptions.sh
# Renders the Docker Hub overview pages from dockerhub/active.md and dockerhub/frozen.md
# and updates the beehivelab repositories through the Docker Hub API.
#
# Usage:
#   dockerhub/update-descriptions.sh <active|frozen|all> [--dry-run <out-dir>]
#
#   active    the supported NVIDIA images (tornadovm-nvidia-{cuda,opencl}-jdk{21,25,27})
#   frozen    the deprecated images, marked as no longer maintained
#   --dry-run write the rendered pages to <out-dir> instead of updating Docker Hub
#
# The active pages show the TornadoVM release in $TORNADOVM_VERSION (X.Y.Z), or build.sh's
# default when unset.
#
# Updating Docker Hub needs DOCKERHUB_USERNAME and DOCKERHUB_TOKEN (a personal access
# token with Read & Write scope and admin rights on the beehivelab repositories). The
# repositories must already exist: run "active" after the images have been pushed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

NAMESPACE=beehivelab
REPO_URL=https://github.com/beehive-lab/docker-tornadovm
## TornadoVM release shown on the active pages: $TORNADOVM_VERSION, else build.sh's default.
VERSION=${TORNADOVM_VERSION:-$(sed -n 's/^TORNADOVM_VERSION="${TORNADOVM_VERSION:-\([^}]*\)}"$/\1/p' build.sh)}
ACTIVE_JDKS=(21 25 27)
LTS_JDK=25

## Frozen images: name|last release|replacement (markdown)|instructions URL|tag to pin
LEGACY_DOCS="$REPO_URL/tree/86ef024#readme"
POLYGLOT_DOCS="$REPO_URL/blob/master/polyglotImages/README.md"
FROZEN=(
    "tornadovm-nvidia-openjdk|7.0.0-jdk21|[\`beehivelab/tornadovm-nvidia-opencl-jdk21\`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-opencl-jdk21) (same OpenCL backend and JDK 21)|$LEGACY_DOCS|7.0.0-jdk21"
    "tornadovm-nvidia-graalvm|7.0.0-jdk21|[\`beehivelab/tornadovm-nvidia-opencl-jdk21\`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-opencl-jdk21). GraalVM-based images are no longer provided|$LEGACY_DOCS|7.0.0-jdk21"
    "tornadovm-intel-openjdk|7.0.0-jdk21|none for Intel devices; images are now provided for NVIDIA GPUs only|$LEGACY_DOCS|7.0.0-jdk21"
    "tornadovm-intel-graalvm|7.0.0-jdk21|none for Intel devices; images are now provided for NVIDIA GPUs only|$LEGACY_DOCS|7.0.0-jdk21"
    "tornadovm-polyglot-graalpy-23.1.0-nvidia-opencl-container|TornadoVM v5.2.0-jdk21, the last release with polyglot GraalVM (Truffle) language support|none; polyglot language support was removed from TornadoVM|$POLYGLOT_DOCS|2.0.0"
    "tornadovm-polyglot-graaljs-23.1.0-nvidia-opencl-container|TornadoVM v5.2.0-jdk21, the last release with polyglot GraalVM (Truffle) language support|none; polyglot language support was removed from TornadoVM|$POLYGLOT_DOCS|2.0.0"
    "tornadovm-polyglot-truffleruby-23.1.0-nvidia-opencl-container|TornadoVM v5.2.0-jdk21, the last release with polyglot GraalVM (Truffle) language support|none; polyglot language support was removed from TornadoVM|$POLYGLOT_DOCS|2.0.0"
    "tornadovm-polyglot-graalpy-23.1.0-oneapi-intel-container|TornadoVM v5.2.0-jdk21, the last release with polyglot GraalVM (Truffle) language support|none; polyglot language support was removed from TornadoVM|$POLYGLOT_DOCS|2.0.0"
)

usage() {
    sed -n '3,15p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
}

die() { echo "ERROR: $*" >&2; exit 1; }

[[ $# -lt 1 ]] && usage
WHICH=$1
OUT_DIR=""
if [[ "${2:-}" == "--dry-run" ]]; then
    OUT_DIR=${3:?--dry-run needs an output directory}
    mkdir -p "$OUT_DIR"
fi
[[ "$WHICH" =~ ^(active|frozen|all)$ ]] || usage
[[ -n "$VERSION" ]] || die "Could not detect TORNADOVM_VERSION from build.sh"

## render <template> KEY=value... : prints the template with each {{KEY}} replaced.
render() {
    python3 - "$@" <<'EOF'
import sys
text = open(sys.argv[1]).read()
for kv in sys.argv[2:]:
    key, value = kv.split("=", 1)
    text = text.replace("{{" + key + "}}", value)
assert "{{" not in text, "unreplaced placeholder in " + sys.argv[1]
sys.stdout.write(text)
EOF
}

TOKEN=""
login() {
    [[ -n "$TOKEN" ]] && return
    : "${DOCKERHUB_USERNAME:?set DOCKERHUB_USERNAME}" "${DOCKERHUB_TOKEN:?set DOCKERHUB_TOKEN}"
    TOKEN=$(python3 -c 'import json,os; print(json.dumps({"username": os.environ["DOCKERHUB_USERNAME"], "password": os.environ["DOCKERHUB_TOKEN"]}))' \
        | curl -sfS -H "Content-Type: application/json" -d @- https://hub.docker.com/v2/users/login \
        | python3 -c 'import json,sys; print(json.load(sys.stdin)["token"])') \
        || die "Docker Hub login failed"
}

## publish <repo> <short description> <markdown file>
publish() {
    local repo=$1 short=$2 file=$3
    (( ${#short} <= 100 )) || die "short description for $repo is over 100 characters"
    if [[ -n "$OUT_DIR" ]]; then
        cp "$file" "$OUT_DIR/$repo.md"
        echo "$short" > "$OUT_DIR/$repo.short.txt"
        echo "  [rendered] $OUT_DIR/$repo.md"
        return
    fi
    login
    python3 -c 'import json,sys; print(json.dumps({"description": sys.argv[1], "full_description": open(sys.argv[2]).read()}))' "$short" "$file" \
        | curl -sfS -o /dev/null -X PATCH -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d @- \
            "https://hub.docker.com/v2/repositories/$NAMESPACE/$repo/" \
        || die "updating $NAMESPACE/$repo failed (does the repository exist?)"
    echo "  [updated]  $NAMESPACE/$repo"
}

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

if [[ "$WHICH" == active || "$WHICH" == all ]]; then
    echo "Active images (TornadoVM $VERSION):"
    for backend in cuda opencl; do
        if [[ $backend == cuda ]]; then
            BACKEND_NAME="CUDA (PTX)"; KERNEL_LANG=PTX
        else
            BACKEND_NAME=OpenCL; KERNEL_LANG="OpenCL C"
        fi
        for jdk in "${ACTIVE_JDKS[@]}"; do
            repo="tornadovm-nvidia-$backend-jdk$jdk"
            JDK_NOTE=""
            [[ $jdk == "$LTS_JDK" ]] && JDK_NOTE=" (LTS)"
            render dockerhub/active.md \
                "IMAGE=$NAMESPACE/$repo" "SHORT=$backend-jdk$jdk" "BACKEND_NAME=$BACKEND_NAME" \
                "KERNEL_LANG=$KERNEL_LANG" "JDK=$jdk" "JDK_NOTE=$JDK_NOTE" "VERSION=$VERSION" \
                > "$TMP/$repo.md"
            publish "$repo" "TornadoVM for NVIDIA GPUs: ${BACKEND_NAME} backend on Eclipse Temurin JDK $jdk" "$TMP/$repo.md"
        done
    done
fi

if [[ "$WHICH" == frozen || "$WHICH" == all ]]; then
    echo "Frozen images:"
    for entry in "${FROZEN[@]}"; do
        IFS='|' read -r repo last replacement docs pin <<< "$entry"
        render dockerhub/frozen.md \
            "IMAGE=$NAMESPACE/$repo" "LAST=$last" "REPLACEMENT=$replacement" "DOCS_URL=$docs" "PIN=$pin" \
            > "$TMP/$repo.md"
        publish "$repo" "FROZEN, no longer maintained. See beehivelab/tornadovm-nvidia-* for current TornadoVM images." "$TMP/$repo.md"
    done
fi
