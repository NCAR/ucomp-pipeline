include(FindPackageHandleStandardArgs)

find_path(IDLdoc_DIR
  idldoc.pro
  PATHS ~/software/idldoc ~/projects/idldoc
  PATH_SUFFIXES src lib
)

if (IDLdoc_DIR)
  set(IDLdoc_FOUND TRUE)
endif()

if (IDLdoc_FOUND)
  if (NOT IDLdoc_FIND_QUIETLY)
    message(STATUS "IDLdoc = ${IDLdoc_DIR}")
  endif ()
else ()
  if (IDLdoc_FIND_REQUIRED)
    message(FATAL_ERROR "Could not find IDLdoc!")
  endif ()
endif ()
