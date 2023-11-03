get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

install(FILES UCOMP_CITATION.txt DESTINATION resource/${DIRNAME})

file(GLOB PDF_FILES "ucomp-user-guide.*.pdf")
install(FILES ${PDF_FILES} ${TXT_FILES} DESTINATION resource/${DIRNAME})
