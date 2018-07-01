nw_project_prepare(CoreFeatures)
add_subdirectory(minizip)
nwstd_add_executable(Deploy ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(Deploy libminizip)

file(GENERATE OUTPUT ${CMAKE_BINARY_DIR}/Project/Scripts/DeployAll.cmake
        CONTENT "include(${CMAKE_BINARY_DIR}/Project/Scripts/DeployHeaders.cmake)
execute_process(COMMAND $<TARGET_FILE:Deploy> -b ${CMAKE_BINARY_DIR} -d ${CMAKE_INSTALL_PREFIX} -a)")
install(SCRIPT ${CMAKE_BINARY_DIR}/Project/Scripts/DeployAll.cmake)
