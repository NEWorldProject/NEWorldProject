#***************************************************************************
# Copyright:  Matthias Schmieder,
# E-Mail:     schmieder.matthias@gmail.com
# Year:       2016
#***************************************************************************
cmake_minimum_required(VERSION 3.9)

option(USE_ZLIB "Enables ZLIB compression" ON)
option(USE_PKCRYPT "Enables PKWARE traditional encryption" ON)
option(USE_AES "Enables AES encryption" ON)
option(COMPRESS_ONLY "Only support compression" OFF)
option(DECOMPRESS_ONLY "Only support decompression" OFF)
option(BUILD_TEST "Builds minizip test executable" ON)

project("minizip")

set(VERSION "2.3.4")

# Set cmake debug postfix to d
set(CMAKE_DEBUG_POSTFIX "d")

# Ensure correct version of zlib is referenced
if(USE_ZLIB)
    set(ZLIB_ROOT ${DEF_ZLIB_ROOT} CACHE PATH "Parent directory of zlib installation")
    find_package(ZLIB REQUIRED)
    if(ZLIB_FOUND)
        include_directories(${ZLIB_INCLUDE_DIRS})
    endif()
    add_definitions(-DHAVE_ZLIB)
endif()

set(PROJECT_NAME libminizip)

set(MINIZIP_SRC
    mz_os.c
    mz_compat.c
    mz_strm.c
    mz_strm_buf.c
    mz_strm_mem.c
    mz_strm_posix.c
    mz_strm_split.c
    mz_zip.c
    minizip.c)

set(MINIZIP_PUBLIC_HEADERS
    mz.h
    mz_os.h
    mz_compat.h
    mz_strm.h
    mz_strm_buf.h
    mz_strm_mem.h
    mz_strm_posix.h
    mz_strm_split.h
    mz_zip.h)

if(COMPRESS_ONLY)
    add_definitions(-DMZ_ZIP_COMPRESS_ONLY)
endif()
if(DECOMPRESS_ONLY)
    add_definitions(-DMZ_ZIP_DECOMPRESS_ONLY)
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

if(WIN32)
    list(APPEND MINIZIP_SRC "mz_os_win32.c" "mz_strm_win32.c")
    list(APPEND MINIZIP_PUBLIC_HEADERS "mz_os_win32.h" "mz_strm_win32.h")

    add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
endif()

if("${CMAKE_SYSTEM_NAME}" STREQUAL "WindowsStore")
    add_definitions(-DMZ_WINRT_API)
endif()

if(UNIX)
    add_compile_options(-O3)

    list(APPEND MINIZIP_SRC "mz_os_posix.c")
    list(APPEND MINIZIP_PUBLIC_HEADERS "mz_os_posix.h")

    set(define_lfs_macros TRUE)

    if(ANDROID)
        string(REGEX REPLACE "android-([0-9+])" "\\1"
            android_api "${ANDROID_PLATFORM}")
        if(${android_api} LESS 24)
            set(define_lfs_macros FALSE)
        endif()
    endif()

    if(define_lfs_macros)
        add_definitions(-D__USE_FILE_OFFSET64)
        add_definitions(-D__USE_LARGEFILE64)
        add_definitions(-D_LARGEFILE64_SOURCE)
        add_definitions(-D_FILE_OFFSET_BITS=64)
    endif()

    if(CMAKE_SYSTEM_NAME MATCHES "Linux")
        find_package(PkgConfig REQUIRED)

        pkg_check_modules(LIBBSD libbsd REQUIRED)

        include_directories(${LIBBSD_INCLUDE_DIRS})
        link_directories(${LIBBSD_LIBRARY_DIRS})
    endif()
endif()

if(USE_PKCRYPT)
    add_definitions(-DHAVE_PKCRYPT)

    list(APPEND MINIZIP_SRC "mz_strm_pkcrypt.c")
    list(APPEND MINIZIP_PUBLIC_HEADERS "mz_strm_pkcrypt.h")
endif()

if(USE_AES)
    add_definitions(-DHAVE_AES)

    list(APPEND MINIZIP_SRC "mz_strm_aes.c")
    list(APPEND MINIZIP_PUBLIC_HEADERS "mz_strm_aes.h")

    set(AES_SRC
        lib/aes/aescrypt.c
        lib/aes/aeskey.c
        lib/aes/aestab.c
        lib/aes/hmac.c
        lib/aes/pwd2key.c
        lib/aes/sha1.c)

    set(AES_PUBLIC_HEADERS
        lib/aes/aes.h
        lib/aes/aesopt.h
        lib/aes/aestab.h
        lib/aes/brg_endian.h
        lib/aes/brg_types.h
        lib/aes/hmac.h
        lib/aes/pwd2key.h
        lib/aes/sha1.h)

    include_directories(lib/aes)

    source_group("AES" FILES ${AES_SRC} ${AES_PUBLIC_HEADERS})
endif()

if(USE_ZLIB)
    add_definitions(-DHAVE_ZLIB)

    list(APPEND MINIZIP_SRC "mz_strm_zlib.c")
    list(APPEND MINIZIP_PUBLIC_HEADERS "mz_strm_zlib.h")

    include(CheckFunctionExists)
    set(CMAKE_REQUIRED_LIBRARIES ZLIB::ZLIB)
    CHECK_FUNCTION_EXISTS(z_get_crc_table
        NEEDS_Z_PREFIX)

    if(NEEDS_Z_PREFIX)
        add_definitions(-DZ_PREFIX)
    endif()
endif()

# Create minizip library
source_group("Minizip" FILES ${MINIZIP_SRC} ${MINIZIP_PUBLIC_HEADERS})

add_library(${PROJECT_NAME} STATIC
                ${MINIZIP_SRC} ${MINIZIP_PUBLIC_HEADERS}
                ${AES_SRC} ${AES_PUBLIC_HEADERS}
                ${BZIP2_SRC} ${BZIP2_PUBLIC_HEADERS}
                ${LZMA_SRC} ${LZMA_PUBLIC_HEADERS})

if (MINGW AND BUILD_SHARED_LIBS)
  set_target_properties(${PROJECT_NAME} PROPERTIES ARCHIVE_OUTPUT_NAME "minizip")
endif ()

set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C PREFIX ""
                      POSITION_INDEPENDENT_CODE 1)
if(USE_ZLIB)
    target_link_libraries(${PROJECT_NAME} ZLIB::ZLIB)
endif()
if(UNIX)
    target_link_libraries(${PROJECT_NAME} ${LIBBSD_LIBRARIES})
endif()

target_include_directories(${PROJECT_NAME} PUBLIC $<INSTALL_INTERFACE:${INSTALL_INC_DIR}>)
