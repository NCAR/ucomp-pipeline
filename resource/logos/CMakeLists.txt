get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB PNG_FILES "*.png")
install(FILES ${PNG_FILES} DESTINATION resource/${DIRNAME})
