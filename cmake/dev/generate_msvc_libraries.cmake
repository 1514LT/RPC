macro(generate_msvc_libraries platform)
    string(COMPARE EQUAL "${platform}" "i86Win32VS2010" IS_I86WIN32VS2010)
    string(COMPARE EQUAL "${platform}" "x64Win64VS2010" IS_X64WIN64VS2010)
    string(COMPARE EQUAL "${platform}" "i86Win32VS2013" IS_I86WIN32VS2013)
    string(COMPARE EQUAL "${platform}" "x64Win64VS2013" IS_X64WIN64VS2013)

    set(CHECKGENERATOR "")
    if(IS_I86WIN32VS2010)
        set(GENERATOR "Visual Studio 10 2010")
    elseif(IS_X64WIN64VS2010)
        set(GENERATOR "Visual Studio 10 2010 Win64")
    elseif(IS_I86WIN32VS2013)
        set(GENERATOR "Visual Studio 12 2013")
    elseif(IS_X64WIN64VS2013)
        set(GENERATOR "Visual Studio 12 2013 Win64")
    else()
        message(FATAL_ERROR "Lexical error defining platform. Trying to use platform \"${platform}\"")
    endif()

    add_custom_target(${PROJECT_NAME}_${platform}_dir
        COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BINARY_DIR}/../${platform}"
        )

    set(_USE_FASTRTPS "")
    set(_USE_RTIDDS "")
    if(RPCPROTO STREQUAL "rpcdds")
        set(_USE_FASTRTPS "-DWITH_FASTRTPS=${WITH_FASTRTPS}")
        set(_USE_RTIDDS "-DWITH_RTIDDS=${WITH_RTIDDS}")
    endif()

    add_custom_target(${PROJECT_NAME}_${platform} ALL
        COMMAND ${CMAKE_COMMAND} -G "${GENERATOR}" -DEPROSIMA_BUILD=${EPROSIMA_BUILD} -DRPCPROTO=${RPCPROTO} ${_USE_FASTRTPS} ${_USE_RTIDDS} ../..
        COMMAND ${CMAKE_COMMAND} --build . --config Release
        COMMAND ${CMAKE_COMMAND} --build . --config Debug
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/../${platform}
        )

    add_dependencies(${PROJECT_NAME}_${platform} ${PROJECT_NAME}_${platform}_dir)
endmacro()

macro(install_msvc_libraries platform)
    install(DIRECTORY ${PROJECT_BINARY_DIR}/../${platform}/lib/
        DESTINATION lib/${platform}
        COMPONENT libraries_${platform}
        FILES_MATCHING
        PATTERN "*${PROJECT_NAME}*-${PROJECT_MAJOR_VERSION}.${PROJECT_MINOR_VERSION}*"
        )
    install(FILES
        ${PROJECT_BINARY_DIR}/../${platform}/cmake/config/${PROJECT_NAME}Config.cmake
        ${PROJECT_BINARY_DIR}/../${platform}/cmake/config/${PROJECT_NAME}ConfigVersion.cmake
        DESTINATION lib/${platform}/${PROJECT_NAME}/cmake
        COMPONENT cmake
        )
    install(FILES
        ${PROJECT_BINARY_DIR}/../${platform}/src/CMakeFiles/Export/lib/${platform}/${PROJECT_NAME}/cmake/${PROJECT_NAME}Targets.cmake
        ${PROJECT_BINARY_DIR}/../${platform}/src/CMakeFiles/Export/lib/${platform}/${PROJECT_NAME}/cmake/${PROJECT_NAME}Targets-release.cmake
        ${PROJECT_BINARY_DIR}/../${platform}/src/CMakeFiles/Export/lib/${platform}/${PROJECT_NAME}/cmake/${PROJECT_NAME}Targets-debug.cmake
        DESTINATION lib/${platform}/${PROJECT_NAME}/cmake
        COMPONENT cmake
        )
    string(TOUPPER "${platform}" ${platform}_UPPER)
    set(CPACK_COMPONENT_LIBRARIES_${${platform}_UPPER}_DISPLAY_NAME "${platform}" PARENT_SCOPE)
    set(CPACK_COMPONENT_LIBRARIES_${${platform}_UPPER}_DESCRIPTION "eProsima ${PROJECT_NAME_LARGE} libraries for platform ${platform}" PARENT_SCOPE)
    set(CPACK_COMPONENT_LIBRARIES_${${platform}_UPPER}_GROUP "Libraries" PARENT_SCOPE)
endmacro()
