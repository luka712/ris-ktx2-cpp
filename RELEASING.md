# Releasing

Releases are built and published to [GitHub Releases](https://github.com/luka712/ris-ktx2-cpp/releases)
by [`publish.yml`](./.github/workflows/publish.yml).

| Push to | GitHub release | Tag |
| --- | --- | --- |
| `develop` | pre-release | `v<version>-dev.<run number>` |
| `main` | release | `v<version>` |

Every release contains one archive per platform plus `SHA256SUMS.txt`:

| Asset | Platform |
| --- | --- |
| `ris_ktx2-v<version>-linux-x64.tar.gz` | Linux x64 |
| `ris_ktx2-v<version>-linux-arm64.tar.gz` | Linux ARM64 |
| `ris_ktx2-v<version>-win-x64.zip` | Windows x64 |
| `ris_ktx2-v<version>-osx-arm64.tar.gz` | macOS Apple Silicon |
| `ris_ktx2-v<version>-osx-x64.tar.gz` | macOS Intel |

Each archive is self-contained (libktx and spdlog are linked statically into the shared library) and has the layout:

```
ris_ktx2-v<version>-<rid>/
  lib/      libris_ktx2.so | libris_ktx2.dylib | ris_ktx2.lib (import lib, Windows)
  bin/      ris_ktx2.dll (Windows only)
  include/ris_ktx2/*.h(pp)
  share/ris_ktx2/LICENSE, THIRD_PARTY_NOTICES.md
```

The workflow builds and runs the tests on every platform before anything is published.

## Cutting a release

1. Bump the version in `CMakeLists.txt` (`project(... VERSION x.y.z)`) and `vcpkg.json`; they must match (the workflow checks this). Update `CHANGELOG.md`.
2. Merge your branch into `develop`: a pre-release is published. Download and try it.
3. Merge `develop` into `main`: the release `v<version>` is published. The workflow fails if that tag already exists, so always bump first.

## Using a release

- **C# (P/Invoke):** take the library from the archive for the platform (`bin/ris_ktx2.dll`, `lib/libris_ktx2.so`, `lib/libris_ktx2.dylib`) and ship it as `runtimes/<rid>/native/`.
- **C / C++:** add `include/` to the include path (headers are in `ris_ktx2/`) and link against `lib/`.
  The headers include `<ktx.h>` and `<vulkan/vulkan.h>`; install the KTX-Software and Vulkan headers for compilation only, no linking required.
