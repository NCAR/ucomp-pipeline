add_subdirectory(calibrate)
add_subdirectory(database)
add_subdirectory(distribute)
add_subdirectory(eod)
add_subdirectory(fileio)
add_subdirectory(level1)
add_subdirectory(level2)
add_subdirectory(realtime)
add_subdirectory(report)
add_subdirectory(reprocess)
add_subdirectory(utils)
add_subdirectory(validate)

configure_file(ucomp_version.pro.in ucomp_version.pro)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/ucomp_version.pro DESTINATION src)

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION src)

