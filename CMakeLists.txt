cmake_minimum_required(VERSION 3.30)
project(ris_ktx2
        VERSION 0.1.0
        DESCRIPTION "Thin C ABI wrapper around Khronos KTX-Software (libktx)"
        HOMEPAGE_URL "https://github.com/luka712/ris-ktx2-cpp"
        LANGUAGES CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# ---------------------------------------------------------------------------
# Options
# ---------------------------------------------------------------------------
if(NOT DEFINED BUILD_SHARED_LIBS)
    # The library is primarily consumed through P/Invoke, so default to shared.
    set(BUILD_SHARED_LIBS ON)
endif()

option(RIS_KTX2_BUILD_TESTS "Build the Catch2 test executable" ${PROJECT_IS_TOP_LEVEL})
option(RIS_KTX2_INSTALL "Generate install rules" ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------
find_package(Ktx CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(VulkanHeaders CONFIG REQUIRED) # only VkFormat is needed, not the loader

# ---------------------------------------------------------------------------
# Library
# ---------------------------------------------------------------------------
set(TARGET_NAME ris_ktx2)

add_library(${TARGET_NAME}
        src/ris_ktx.cpp
        src/ris_ktx_logging.cpp
        src/ris_stb_image.cpp
)
add_library(ris_ktx2::ris_ktx2 ALIAS ${TARGET_NAME})

target_compile_features(${TARGET_NAME} PUBLIC cxx_std_20)

target_include_directories(${TARGET_NAME}
        PUBLIC
            "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
            "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
        PRIVATE
            "${CMAKE_CURRENT_SOURCE_DIR}/vendor"
)

target_link_libraries(${TARGET_NAME}
        PUBLIC
            Vulkan::Headers
        PRIVATE
            spdlog::spdlog
)

if(BUILD_SHARED_LIBS)
    # Public headers include <ktx.h>, but consumers must not link libktx themselves:
    # it is already part of the shared library.
    target_link_libraries(${TARGET_NAME} PUBLIC $<COMPILE_ONLY:KTX::ktx> PRIVATE KTX::ktx)
else()
    target_link_libraries(${TARGET_NAME} PUBLIC KTX::ktx)
endif()

if(BUILD_SHARED_LIBS)
    target_compile_definitions(${TARGET_NAME} PRIVATE RIS_KTX2_BUILDING)
else()
    target_compile_definitions(${TARGET_NAME} PUBLIC RIS_KTX2_STATIC)
endif()

set_target_properties(${TARGET_NAME} PROPERTIES EXPORT_NAME ris_ktx2)
if(NOT ANDROID) # Android packaging requires a plain libris_ktx2.so (no versioned soname)
    set_target_properties(${TARGET_NAME} PROPERTIES
            VERSION ${PROJECT_VERSION}
            SOVERSION ${PROJECT_VERSION_MAJOR})
endif()

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------
if(RIS_KTX2_BUILD_TESTS)
    find_package(Catch2 CONFIG REQUIRED)

    set(TESTS_NAME ${TARGET_NAME}_tests)
    file(GLOB TEST_SRC_FILES CONFIGURE_DEPENDS tests/*.cpp)

    add_executable(${TESTS_NAME} ${TEST_SRC_FILES})
    target_link_libraries(${TESTS_NAME} PRIVATE
            ${TARGET_NAME}
            KTX::ktx        # the tests call libktx directly; ris_ktx2 does not re-export it when built shared
            spdlog::spdlog
            Catch2::Catch2
            Catch2::Catch2WithMain
    )

    # Tests load their input files relative to the working directory.
    file(COPY test_files DESTINATION ${CMAKE_BINARY_DIR})
endif()

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------
if(RIS_KTX2_INSTALL)
    install(TARGETS ${TARGET_NAME}
            EXPORT ris_ktx2Targets
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )

    # Public headers live in <prefix>/include/ris_ktx2/.
    install(DIRECTORY include/
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/ris_ktx2
            FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp")

    install(EXPORT ris_ktx2Targets
            NAMESPACE ris_ktx2::
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/ris_ktx2)

    configure_package_config_file(
            cmake/ris_ktx2Config.cmake.in
            "${CMAKE_CURRENT_BINARY_DIR}/ris_ktx2Config.cmake"
            INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/ris_ktx2)
    write_basic_package_version_file(
            "${CMAKE_CURRENT_BINARY_DIR}/ris_ktx2ConfigVersion.cmake"
            VERSION ${PROJECT_VERSION}
            COMPATIBILITY SameMajorVersion)

    install(FILES
            "${CMAKE_CURRENT_BINARY_DIR}/ris_ktx2Config.cmake"
            "${CMAKE_CURRENT_BINARY_DIR}/ris_ktx2ConfigVersion.cmake"
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/ris_ktx2)

    install(FILES LICENSE THIRD_PARTY_NOTICES.md
            DESTINATION ${CMAKE_INSTALL_DATADIR}/ris_ktx2)
endif()
