include(FindPackageHandleStandardArgs)

find_path(mgunit_DIR
  mgunit.pro
  PATHS ~/software/mgunit ~/projects/mgunit
  PATH_SUFFIXES src lib
)

if (mgunit_DIR)
  set(mgunit_FOUND TRUE)
endif ()

if (mgunit_FOUND)
  if (NOT mgunit_FIND_QUIETLY)
    message(STATUS "mgunit = ${mgunit_DIR}")
  endif ()
else ()
  if (mgunit_FIND_REQUIRED)
    message(FATAL_ERROR "Could not find mgunit!")
  endif ()
endif ()
