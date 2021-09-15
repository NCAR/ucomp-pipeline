get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB TBL_FILES "*.tbl")
install(FILES ${TBL_FILES} DESTINATION resource/${DIRNAME})
