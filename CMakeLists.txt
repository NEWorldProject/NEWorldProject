cmake_minimum_required(VERSION 3.9)
project(NEWorld)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMake)

include(BootStrap)
include(Commands)

nw_module(Core 0.0.1 INFINIDEAS)

add_subdirectory(Common)
add_subdirectory(Libs)
add_subdirectory(Tools)
