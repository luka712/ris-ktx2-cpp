#!/bin/bash
# Publishes ports/ris-ktx2 as <version> into the ris-vcpkg-registry checkout.
#
# Usage: scripts/publish_to_registry.sh <version> <registry-checkout-dir>
#   <version>  e.g. 0.1.0 (release) or 0.1.0-dev.12 (pre-release); the tag v<version> must already exist on GitHub.
#
# Requires: curl, sha512sum, git, and VCPKG_ROOT pointing to a bootstrapped vcpkg checkout.
# Commits to the registry checkout but does NOT push; the caller pushes.
set -euo pipefail

VERSION="${1:?usage: $0 <version> <registry-dir>}"
REGISTRY="$(cd "${2:?usage: $0 <version> <registry-dir>}" && pwd)"
SRC_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
: "${VCPKG_ROOT:?VCPKG_ROOT must be set}"
REPO="${GITHUB_REPOSITORY:-luka712/ris-ktx2-cpp}"

URL="${ARCHIVE_URL:-https://github.com/${REPO}/archive/refs/tags/v${VERSION}.tar.gz}"   # ARCHIVE_URL override is for local testing
echo "Hashing $URL"
SHA=$(curl -fsSL --retry 5 "$URL" | sha512sum | cut -d' ' -f1)

PORT_DIR="$REGISTRY/ports/ris-ktx2"
rm -rf "$PORT_DIR"
mkdir -p "$PORT_DIR"
cp "$SRC_ROOT"/ports/ris-ktx2/* "$PORT_DIR/"

# Pin the portfile to this release and stamp the version.
sed -i -E "s/SHA512 [0-9a-f]+.*/SHA512 ${SHA}/" "$PORT_DIR/portfile.cmake"
sed -i -E "s|^    REPO .*|    REPO ${REPO}|" "$PORT_DIR/portfile.cmake"
python3 - "$PORT_DIR/vcpkg.json" "$VERSION" <<'PY'
import json, sys
p, v = sys.argv[1:3]
d = json.load(open(p))
d.pop("version", None); d.pop("version-semver", None)
new = {}
for k, val in d.items():
    new[k] = val
    if k == "name":
        new["version-semver"] = v
json.dump(new, open(p, "w"), indent=2)
open(p, "a").write("\n")
PY

"$VCPKG_ROOT/vcpkg" format-manifest "$PORT_DIR/vcpkg.json"

cd "$REGISTRY"
git add ports/ris-ktx2
if git diff --cached --quiet; then
  echo "Port unchanged, nothing to publish."; exit 0
fi
git commit -q -m "ris-ktx2 ${VERSION}"      # x-add-version needs the port tree committed
"$VCPKG_ROOT/vcpkg" x-add-version ris-ktx2 \
  --x-builtin-ports-root="$REGISTRY/ports" \
  --x-builtin-registry-versions-dir="$REGISTRY/versions"
git add versions
git commit -q -m "Add ris-ktx2 ${VERSION} to version database"
echo "Registry updated with ris-ktx2 ${VERSION}"
