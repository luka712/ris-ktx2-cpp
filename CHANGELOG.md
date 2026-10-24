# Changelog

## [0.1.0] - Unreleased

### Added
- Release archives ship the license texts of all bundled third-party code (`third_party/`).
- Standalone repository for the native library (split out of `RisKtx2`).
- Installable CMake package (`ris_ktx2::ris_ktx2`) and install rules (headers go to `include/ris_ktx2/`).
- GitHub Actions: CI plus release publishing with prebuilt binaries for Linux, Windows and macOS.
- Static library support (`BUILD_SHARED_LIBS=OFF`).

### Changed
- Headers are installed to `include/ris_ktx2/`.
- Depends on `vulkan-headers` instead of the full Vulkan loader.
- Tests are optional (`RIS_KTX2_BUILD_TESTS`) and no longer built when consumed as a dependency.
- `CMAKE_OSX_ARCHITECTURES` is no longer hard-coded; the macOS scripts pass it.
