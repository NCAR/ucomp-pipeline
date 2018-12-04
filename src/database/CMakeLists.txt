get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION src/${DIRNAME})

file(GLOB TBL_FILES "*.tbl")
install(FILES ${TBL_FILES} DESTINATION src/${DIRNAME})
