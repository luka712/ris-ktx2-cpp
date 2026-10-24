# Changelog

## [0.1.0] - Unreleased

### Added
- Standalone repository for the native library (split out of `RisKtx2`).
- vcpkg port (`ports/ris-ktx2`) and installable CMake package (`find_package(ris_ktx2 CONFIG)`, target `ris_ktx2::ris_ktx2`).
- Static library support (`BUILD_SHARED_LIBS=OFF`).

### Changed
- Headers are installed to `include/ris_ktx2/`.
- Depends on `vulkan-headers` instead of the full Vulkan loader.
- Tests are optional (`RIS_KTX2_BUILD_TESTS`) and no longer built when consumed as a dependency.
- `CMAKE_OSX_ARCHITECTURES` is no longer hard-coded; the macOS scripts pass it.
