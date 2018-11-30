add_subdirectory(level1)
add_subdirectory(level2)

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION src/eod)
