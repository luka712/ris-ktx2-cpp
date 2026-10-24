vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luka712/ris-ktx2-cpp
    REF "v${VERSION}"
    SHA512 0  # placeholder: filled in by scripts/publish_to_registry.sh
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRIS_KTX2_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ris_ktx2 CONFIG_PATH lib/cmake/ris_ktx2)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/ris_ktx2/LICENSE" "${CURRENT_PACKAGES_DIR}/share/ris_ktx2/THIRD_PARTY_NOTICES.md")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/THIRD_PARTY_NOTICES.md")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
