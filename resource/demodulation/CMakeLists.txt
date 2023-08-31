get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

file(GLOB SAV_FILES "ucomp.*.dmx-temp-coeffs.*.sav")
install(FILES ${SAV_FILES} DESTINATION resource/${DIRNAME})
