# Install Utilities
function(nwstd_install_include_files SOURCE_DIR)
    install(DIRECTORY ${SOURCE_DIR}/Source/
            DESTINATION ${CMAKE_INSTALL_PREFIX}/SDK/Include
            FILES_MATCHING PATTERN "*.h")

    if (EXISTS ${SOURCE_DIR}/3rdParty)
        install(DIRECTORY ${SOURCE_DIR}/3rdParty/
                DESTINATION ${CMAKE_INSTALL_PREFIX}/SDK/Include)
    endif ()
endfunction()

function(nwstd_install_targets)
    install(TARGETS ${ARGV}
            RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/Product-$<CONFIG>
            LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/Product-$<CONFIG>
            ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/SDK/Lib)
endfunction()

# Standard Target Utilities
function(nwstd_target_define_common_properties NAME DIRECTORY)
    target_enable_ipo(${NAME})
    # Set Target Include Directories
    target_include_directories(${NAME} PUBLIC ${DIRECTORY}/Source)
    nwstd_install_targets(${NAME})
    if (EXISTS ${DIRECTORY}/3rdParty)
        target_include_directories(${NAME} PUBLIC ${DIRECTORY}/3rdParty)
        target_include_directories(${NAME} SYSTEM PUBLIC ${DIRECTORY}/3rdParty)
    endif()
    # Target Install Script
    nwstd_install_targets(${NAME})
    nwstd_install_include_files(${DIRECTORY})
    # Set Target Name Macro
    target_compile_definitions(${NAME} PRIVATE -DNW_COMPONENT_NAME="${NAME}")
endfunction()

function(nwstd_add_executable NAME DIRECTORY)
    file(GLOB_RECURSE SRC DIRECTORY ${DIRECTORY}/Source/*.*)
    add_executable(${NAME} ${SRC})
    nwstd_target_define_common_properties(${NAME} ${DIRECTORY})
endfunction()

function(nwstd_add_library NAME TYPE DIRECTORY)
    file(GLOB_RECURSE SRC DIRECTORY ${DIRECTORY}/Source/*.*)
    add_library(${NAME} ${TYPE} ${SRC})
    nwstd_target_define_common_properties(${NAME} ${DIRECTORY})
    # Add Shared Library Export Flag
    if (TYPE STREQUAL "SHARED")
        string(TOUPPER ${NAME} NAME_IN_UPPER_CASE)
        target_compile_definitions(${NAME} PRIVATE NW_${NAME_IN_UPPER_CASE}_EXPORTS)
    endif()
endfunction()
