###############################################################################
# Set common CPACK variables.
###############################################################################

set(CPACK_PACKAGE_NAME ${PROJECT_NAME})

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${CPACK_PACKAGE_NAME} - ${${PROJECT_NAME}_DESCRIPTION_SUMMARY}")

set(CPACK_PACKAGE_DESCRIPTION "${${PROJECT_NAME}_DESCRIPTION}")

set(CPACK_PACKAGE_VENDOR "eProsima")
set(CPACK_PACKAGE_CONTACT "eProsima Support <support@eprosima.com>")

set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_MAJOR_VERSION})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_MINOR_VERSION})
set(CPACK_PACKAGE_VERSION_PATH ${PROJECT_MICRO_VERSION})
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})

set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/${PROJECT_NAME_UPPER}_LICENSE.txt")

###############################################################################
# Create CMake package config file
###############################################################################
if(NOT((MSVC OR MSVC_IDE) AND EPROSIMA_INSTALLER))
    include(CMakePackageConfigHelpers)

    if(RPCPROTO STREQUAL "fastrpc" OR RPCPROTO STREQUAL "rpcdds")
        set(EPROSIMA_FIND_DEPENDENCIES
            "if(NOT fastcdr_FOUND)\n    find_package(fastcdr REQUIRED)\nendif()\n")
    endif()

    if(RPCPROTO STREQUAL "rpcdds" AND WITH_FASTRTPS)
        set(EPROSIMA_FIND_DEPENDENCIES
            "if(NOT fastrtps_FOUND)\n    find_package(fastcdr REQUIRED)\nendif()\n")
    endif()

    configure_package_config_file(${PROJECT_SOURCE_DIR}/cmake/packaging/Config.cmake.in
        ${PROJECT_BINARY_DIR}/cmake/config/${PROJECT_NAME}Config.cmake
        INSTALL_DESTINATION ${LIB_INSTALL_DIR}/${PROJECT_NAME}/cmake
        PATH_VARS INCLUDE_INSTALL_DIR LIB_INSTALL_DIR
        )
    write_basic_package_version_file(${PROJECT_BINARY_DIR}/cmake/config/${PROJECT_NAME}ConfigVersion.cmake
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
        )
    install(FILES ${PROJECT_BINARY_DIR}/cmake/config/${PROJECT_NAME}Config.cmake
        ${PROJECT_BINARY_DIR}/cmake/config/${PROJECT_NAME}ConfigVersion.cmake
        DESTINATION ${LIB_INSTALL_DIR}/${PROJECT_NAME}/cmake
        COMPONENT cmake
        )
endif()

set(CPACK_COMPONENT_CMAKE_HIDDEN 1)
set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL} cmake)

###############################################################################
# Platform and architecture dependant
###############################################################################
if(WIN32)
    set(CPACK_GENERATOR NSIS)

    configure_file(${PROJECT_SOURCE_DIR}/cmake/packaging/windows/WindowsPackaging.cmake.in ${PROJECT_BINARY_DIR}/cmake/packaging/windows/WindowsPackaging.cmake @ONLY)
    configure_file(${PROJECT_SOURCE_DIR}/cmake/packaging/windows/NSISPackaging.cmake.in ${PROJECT_BINARY_DIR}/cmake/packaging/windows/NSISPackaging.cmake @ONLY)

    # Update CMAKE_MODULE_PATH to find NSIS.template.in
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake/packaging/windows")

    # Set cpack project config file.
    set(CPACK_PROJECT_CONFIG_FILE ${PROJECT_BINARY_DIR}/cmake/packaging/windows/WindowsPackaging.cmake)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    set(CPACK_GENERATOR TGZ)
    set(CPACK_SOURCE_GENERATOR TGZ)

    # Prepare specific cmake scripts
    configure_file(${PROJECT_SOURCE_DIR}/cmake/packaging/linux/LinuxPackaging.cmake.in ${PROJECT_BINARY_DIR}/cmake/packaging/linux/LinuxPackaging.cmake @ONLY)

    if(RPCPROTO STREQUAL "rpcdds")
        set(AUTOTOOLS_CONFIGURE_AC_FILE ${PROJECT_BINARY_DIR}/configure_${PROJECT_NAME}.ac)
        include(${PROJECT_SOURCE_DIR}/cmake/packaging/linux/generate_configure_ac.cmake)
        generate_rpcdds_configure_ac()
    else()
        set(AUTOTOOLS_CONFIGURE_AC_FILE ${PROJECT_SOURCE_DIR}/configure_${PROJECT_NAME}.ac)
    endif()

    configure_file(${PROJECT_SOURCE_DIR}/cmake/packaging/linux/AutotoolsPackaging.cmake.in ${PROJECT_BINARY_DIR}/cmake/packaging/linux/AutotoolsPackaging.cmake @ONLY)

    # Prepare scripts for autotools
    include(${PROJECT_SOURCE_DIR}/cmake/packaging/linux/autotools_generator_utility.cmake)
    generate_autotools_generator_script()

    # Set cpack project config file.
    set(CPACK_PROJECT_CONFIG_FILE ${PROJECT_BINARY_DIR}/cmake/packaging/linux/LinuxPackaging.cmake)
endif()

include(CPack)
