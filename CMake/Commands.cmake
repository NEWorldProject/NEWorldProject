# Install Utilities
function(nwstd_install_include_files NAME SOURCE_DIR)
    file(GENERATE OUTPUT ${CMAKE_BINARY_DIR}/Project/Scripts/Targets/${NAME}.cmake CONTENT
"file(COPY ${SOURCE_DIR}/Source/
    DESTINATION ${CMAKE_INSTALL_PREFIX}/Modules/${NW_CURRENT_MODULE}/SDK-$<CONFIG>/Include
    FILES_MATCHING PATTERN \"*.h\")

if (EXISTS ${SOURCE_DIR}/3rdParty)
    file(COPY ${SOURCE_DIR}/3rdParty/
         DESTINATION ${CMAKE_INSTALL_PREFIX}/Modules/${NW_CURRENT_MODULE}/SDK-$<CONFIG>/Include)
endif ()")
    file(APPEND ${CMAKE_BINARY_DIR}/Project/Scripts/DeployHeaders.cmake
            "include(${CMAKE_BINARY_DIR}/Project/Scripts/Targets/${NAME}.cmake)\n")
endfunction()


# Standard Target Utilities
function(nwstd_target_define_common_properties NAME DIRECTORY)
    target_enable_ipo(${NAME})
    # Set Target Include Directories
    target_include_directories(${NAME} PUBLIC ${DIRECTORY}/Source)
    if (EXISTS ${DIRECTORY}/3rdParty)
        target_include_directories(${NAME} PUBLIC ${DIRECTORY}/3rdParty)
        target_include_directories(${NAME} SYSTEM PUBLIC ${DIRECTORY}/3rdParty)
    endif()
    # Target Install Script
    nwstd_install_include_files(${NAME} ${DIRECTORY})
    # Set Target Name Macro
    target_compile_definitions(${NAME} PRIVATE -DNW_COMPONENT_NAME="${NAME}")
    # Common Target Link Libraries
    if (NOT NAME STREQUAL "Core")
        target_link_libraries(${NAME} Core)
    endif()
    # Add Module Info
    nw_module_target(${NW_CURRENT_MODULE} ${NAME})
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

function(nw_module NAME VERSION AUTHOR)
    file(WRITE ${CMAKE_BINARY_DIR}/Project/Modules/${NAME}
            "NAME=${NAME}\n"
            "VERSION=${VERSION}\n"
            "AUTHOR=${AUTHOR}\n")
endfunction()

function(nw_module_target MODULE NAME)
    file(APPEND ${CMAKE_BINARY_DIR}/Project/Modules/${MODULE} "TARGET=${NAME}\n")
endfunction()

function(nw_add_subdirectories)
    file(GLOB MODULE_DIRS *)
    foreach(DIR IN LISTS MODULE_DIRS)
        if(IS_DIRECTORY ${DIR})
            if (EXISTS "${DIR}/CMakeLists.txt")
                add_subdirectory(${DIR})
            endif()
        endif()
    endforeach()
endfunction()

macro(nw_project_prepare MODULE)
    set(NW_CURRENT_MODULE ${MODULE})
    set(NW_CURRENT_OUTPUT_ROOT ${CMAKE_BINARY_DIR}/Modules/${MODULE})
    set(SDK_DIR ${NW_CURRENT_OUTPUT_ROOT}/SDK-$<CONFIG>)
    set(PRODUCT_DIR ${NW_CURRENT_OUTPUT_ROOT}/Product-$<CONFIG>)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${SDK_DIR}/Lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PRODUCT_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PRODUCT_DIR})
    if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/CMake)
        list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake")
    endif()
endmacro()
