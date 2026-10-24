#!/bin/bash
# Usage: scripts/update_port_sha.sh <version>   (the tag v<version> must already be pushed)
# Downloads the GitHub tag archive, computes its SHA512 and writes it into ports/ris-ktx2/portfile.cmake.
set -euo pipefail
VERSION="${1:?usage: $0 <version>}"
URL="https://github.com/luka712/ris-ktx2-cpp/archive/refs/tags/v${VERSION}.tar.gz"
SHA=$(curl -fsSL "$URL" | sha512sum | cut -d' ' -f1)
sed -i -E "s/SHA512 [0-9a-f]+.*/SHA512 ${SHA}/" "$(dirname "$0")/../ports/ris-ktx2/portfile.cmake"
echo "SHA512 for v${VERSION}: ${SHA}"
