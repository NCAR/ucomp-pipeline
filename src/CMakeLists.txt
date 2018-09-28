add_subdirectory(database)
add_subdirectory(fileio)
add_subdirectory(level1)
add_subdirectory(level2)
add_subdirectory(utils)

configure_file(ucomp_version.pro.in ucomp_version.pro)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/ucomp_version.pro DESTINATION src)

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION src)

#file(GLOB SAV_FILES "*.sav")
#install(FILES ${SAV_FILES} DESTINATION src)

install(FILES epochs.cfg DESTINATION src)
