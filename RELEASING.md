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
| `ris_ktx2-v<version>-win-arm64.zip` | Windows ARM64 |
| `ris_ktx2-v<version>-osx-arm64.tar.gz` | macOS Apple Silicon |
| `ris_ktx2-v<version>-osx-x64.tar.gz` | macOS Intel |
| `ris_ktx2-v<version>-ios-xcframework.zip` | iOS and iPadOS (device arm64 + simulator arm64), static |
| `ris_ktx2-v<version>-android.zip` | Android (`arm64-v8a`, `x86_64`), API 28+ |

Each archive is self-contained (libktx and spdlog are linked statically into the shared library) and has the layout:

```
ris_ktx2-v<version>-<rid>/
  lib/      libris_ktx2.so | libris_ktx2.dylib | ris_ktx2.lib (import lib, Windows)
  bin/      ris_ktx2.dll (Windows only)
  include/ris_ktx2/*.h(pp)
  share/ris_ktx2/LICENSE, THIRD_PARTY_NOTICES.md
```

The workflow builds and runs the tests on every desktop platform before anything is published. The iOS and Android builds are cross-compiled and are not tested in CI.

## Cutting a release

1. Bump the version in `CMakeLists.txt` (`project(... VERSION x.y.z)`) and `vcpkg.json`; they must match (the workflow checks this). Update `CHANGELOG.md`.
2. Merge your branch into `develop`: a pre-release is published. Download and try it.
3. Merge `develop` into `main`: the release `v<version>` is published. The workflow fails if that tag already exists, so always bump first.

### Mobile layouts

```
ris_ktx2-v<version>-ios-xcframework/
  ris_ktx2.xcframework/   static library (ktx, zstd, astcenc, spdlog merged in) + headers
  licenses/
ris_ktx2-v<version>-android/
  jniLibs/arm64-v8a/libris_ktx2.so
  jniLibs/x86_64/libris_ktx2.so
  include/ris_ktx2/
  licenses/
```

On iOS the library is static, so from C# use `[DllImport("__Internal")]` and link the XCFramework into the app.
On Android copy `jniLibs/` into the app (Unity: `Assets/Plugins/Android/libs/<abi>/`).

## Using a release

- **C# (P/Invoke):** take the library from the archive for the platform (`bin/ris_ktx2.dll`, `lib/libris_ktx2.so`, `lib/libris_ktx2.dylib`) and ship it as `runtimes/<rid>/native/`.
- **C / C++:** add `include/` to the include path (headers are in `ris_ktx2/`) and link against `lib/`.
  The headers include `<ktx.h>` and `<vulkan/vulkan.h>`; install the KTX-Software and Vulkan headers for compilation only, no linking required.
