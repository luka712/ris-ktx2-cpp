#!/bin/bash
# Copies the license texts of the vcpkg dependencies that end up inside the binaries into a folder
# that is shipped with each release (Apache-2.0, BSD and MIT all require the license text to travel with binaries).
#
# Usage: scripts/collect_licenses.sh <vcpkg_installed/<triplet> dir> <destination dir>
set -euo pipefail
INSTALLED="${1:?usage: $0 <vcpkg_installed/triplet> <dest>}"
DEST="${2:?usage: $0 <vcpkg_installed/triplet> <dest>}"
mkdir -p "$DEST"
for port in "$INSTALLED"/share/*/; do
  name="$(basename "$port")"
  case "$name" in
    vcpkg-cmake|vcpkg-cmake-config|catch2|Catch2|cmake|pkgconfig|ris-ktx2|ris_ktx2) continue ;;
  esac
  if [ -f "$port/copyright" ]; then
    cp "$port/copyright" "$DEST/${name}.copyright.txt"
  fi
  # KTX-Software ships the full text of every license used in it (Apache-2.0, BSD, MIT, Zlib, Ericsson ETC SLA, ...)
  if [ -d "$port/LICENSES" ]; then
    mkdir -p "$DEST/${name}-LICENSES"
    cp "$port"/LICENSES/* "$DEST/${name}-LICENSES/"
  fi
done
ls "$DEST"
