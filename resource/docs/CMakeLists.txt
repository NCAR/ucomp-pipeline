get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB DOC_FILES "ucomp-citation.txt")
install(FILES ${DOC_FILES} DESTINATION resource/${DIRNAME})
