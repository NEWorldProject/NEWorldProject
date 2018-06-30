nw_project_prepare()
nwstd_add_executable(ProjectManager ${CMAKE_CURRENT_SOURCE_DIR})
nw_module_target(DevTools ProjectManager)

find_package(LibGit2 REQUIRED)
target_link_libraries(ProjectManager libgit2)
