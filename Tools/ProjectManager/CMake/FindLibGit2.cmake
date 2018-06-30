# - Try to find the libgit2 library
# Once done this will define
#
#  LIBGIT2_FOUND - System has libgit2
#  LIBGIT2_INCLUDE_DIR - The libgit2 include directory
#  LIBGIT2_LIBRARIES - The libraries needed to use libgit2
#  LIBGIT2_DEFINITIONS - Compiler switches required for using libgit2

SET(LIBGIT2_DEFINITIONS ${PC_LIBGIT2_CFLAGS_OTHER})

FIND_PATH(LIBGIT2_INCLUDE_DIR NAMES git2.h
        HINTS
        ${PC_LIBGIT2_INCLUDEDIR}
        ${PC_LIBGIT2_INCLUDE_DIRS}
        )

FIND_LIBRARY(LIBGIT2_LIBRARIES NAMES git2
        HINTS
        ${PC_LIBGIT2_LIBDIR}
        ${PC_LIBGIT2_LIBRARY_DIRS}
        )

INCLUDE(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(libgit2 DEFAULT_MSG LIBGIT2_LIBRARIES LIBGIT2_INCLUDE_DIR)

MARK_AS_ADVANCED(LIBGIT2_INCLUDE_DIR LIBGIT2_LIBRARIES)

if(LIBGIT2_FOUND)
    set(CMAKE_IMPORT_FILE_VERSION 1)
    add_library(libgit2 INTERFACE)
    target_compile_options(libgit2 INTERFACE "${LIBGIT2_CFLAGS_OTHER}")
    target_compile_options(
            libgit2 INTERFACE
            "${LIBGIT2_DEFINITIONS}"
    )
    target_include_directories(
            libgit2 INTERFACE
            "${LIBGIT2_INCLUDE_DIR}"
    )
    target_link_libraries(
            libgit2 INTERFACE
            "${LIBGIT2_LIBRARIES}"
    )
    set(LIBGIT2_LIBRARY libgit2)
    set(CMAKE_IMPORT_FILE_VERSION)
endif()
