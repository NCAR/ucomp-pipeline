get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB SAV_FILES "*.sav")
install(FILES ${SAV_FILES} DESTINATION resource/${DIRNAME})

file(GLOB CFG_FILES "*.cfg")
install(FILES ${CFG_FILES} DESTINATION resource/${DIRNAME})
