get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

configure_file(UCOMP_CITATION.txt.in UCOMP_CITATION.txt @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/UCOMP_CITATION.txt
        DESTINATION resource/${DIRNAME})

file(GLOB PDF_FILES "ucomp-user-guide.*.pdf")
install(FILES ${PDF_FILES} ${TXT_FILES} DESTINATION resource/${DIRNAME})
