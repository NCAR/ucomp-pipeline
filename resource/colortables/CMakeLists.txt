get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB SAV_FILES "*.sav")
install(FILES ${SAV_FILES} DESTINATION resource/${DIRNAME})
file(GLOB TBL_FILES "*.tbl")
install(FILES ${TBL_FILES} DESTINATION resource/${DIRNAME})
