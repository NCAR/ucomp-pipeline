get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB SPEC_FILES "*.cfg")
install(FILES ${SPEC_FILES} DESTINATION resource/${DIRNAME})
