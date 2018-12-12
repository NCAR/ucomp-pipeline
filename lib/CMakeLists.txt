add_subdirectory(mpfit)
add_subdirectory(mysql)

file(GLOB PRO_FILES "*.pro")

configure_file(mg_dist_tools.dlm.in mg_dist_tools.dlm)
add_library(mg_dist_tools SHARED mg_dist_tools.c)

if (UNIX)
  set_target_properties(mg_dist_tools
    PROPERTIES
      SUFFIX ".${IDL_PLATFORM_EXT}.so"
  )
endif ()

set_target_properties(mg_dist_tools
  PROPERTIES
    PREFIX ""
)

target_link_libraries(mg_dist_tools ${IDL_LIBRARY})

install(TARGETS mg_dist_tools
  RUNTIME DESTINATION lib
  LIBRARY DESTINATION lib
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/mg_dist_tools.dlm" DESTINATION lib)
install(FILES ${PRO_FILES} DESTINATION lib)
install(FILES profiler.tt DESTINATION lib)
