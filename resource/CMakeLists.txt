get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

add_subdirectory(logos)

file(GLOB CFG_FILES "*.cfg")
install(FILES ${CFG_FILES} DESTINATION ${DIRNAME})

file(GLOB SAV_FILES "*.sav")
install(FILES ${SAV_FILES} DESTINATION ${DIRNAME})
