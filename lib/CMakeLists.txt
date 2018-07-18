add_subdirectory(mpfit)
add_subdirectory(mysql)

file(GLOB PRO_FILES "*.pro")
install(FILES ${PRO_FILES} DESTINATION lib)
