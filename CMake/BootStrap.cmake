# Set Env Options
set(CMAKE_MACOSX_RPATH ON)
set(CMAKE_CXX_STANDARD 17)

# Set Project Build Output Directories
set(PROJECT_DIR ${CMAKE_SOURCE_DIR})
file(REMOVE ${CMAKE_BINARY_DIR}/Project/Scripts/DeployHeaders.cmake)

# Check IPO Support
cmake_policy(SET CMP0069 NEW)
include(CheckIPOSupported)
check_ipo_supported(RESULT NWCONF_IPO_SUPPORT OUTPUT NWCONF_IPO_SUPPORT_MESSAGE)
if (NWCONF_IPO_SUPPORT)
    message(STATUS "IPO IS SUPPORTED, ENABLED")
else()
    message(STATUS "IPO IS NOT SUPPORTED: ${NWCONF_IPO_SUPPORT_MESSAGE}, DISABLED")
endif ()

function(target_enable_ipo NAME)
    if (NWCONF_IPO_SUPPORT)
        set_property(TARGET ${NAME} PROPERTY INTERPROCEDURAL_OPTIMIZATION $<$<CONFIG:Debug>:FALSE>:TRUE)
    endif ()
endfunction()

# Enable Filesystem
if((UNIX OR MINGW) AND (NOT APPLE))
    link_libraries(stdc++fs)
endif()

# Enable Multi-threaded
find_package(Threads REQUIRED)
link_libraries(Threads::Threads)
