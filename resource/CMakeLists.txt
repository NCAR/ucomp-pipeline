get_filename_component(DIRNAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

add_subdirectory(colortables)
add_subdirectory(database)
add_subdirectory(demodulation)
add_subdirectory(distortion)
add_subdirectory(logos)
add_subdirectory(validation)

file(GLOB CFG_FILES "*.cfg")
install(FILES ${CFG_FILES} DESTINATION ${DIRNAME})

file(GLOB SAV_FILES "*.sav")
install(FILES ${SAV_FILES} DESTINATION ${DIRNAME})
