nw_project_prepare(Core)
nwstd_add_executable(Manager ${CMAKE_CURRENT_SOURCE_DIR})
find_package(LibGit2 REQUIRED)
target_link_libraries(Manager libgit2)
