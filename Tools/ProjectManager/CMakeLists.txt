nw_project_prepare(CoreFeatures)
nwstd_add_executable(ProjectManager ${CMAKE_CURRENT_SOURCE_DIR})
find_package(LibGit2 REQUIRED)
target_link_libraries(ProjectManager libgit2)
