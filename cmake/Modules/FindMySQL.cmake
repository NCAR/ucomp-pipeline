# - Find mysqlclient
# Find the native MySQL includes and library
#
#  MYSQL_INCLUDE_DIR - where to find mysql.h, etc.
#  MYSQL_LIBRARIES   - List of libraries when using MySQL.
#  MYSQL_FOUND       - True if MySQL found.

if (MYSQL_INCLUDE_DIR)
  # already in cache, be silent
  set(MYSQL_FIND_QUIETLY TRUE)
endif ()

find_path(MYSQL_INCLUDE_DIR mysql.h
  /usr/local/include/mysql
  /usr/include/mysql
)

set(MYSQL_NAMES mysqlclient mysqlclient_r)
find_library(MYSQL_LIBRARY
  NAMES ${MYSQL_NAMES}
  PATHS /usr/lib /usr/local/lib
  PATH_SUFFIXES mysql
)

if (MYSQL_INCLUDE_DIR AND MYSQL_LIBRARY)
  set(MYSQL_FOUND TRUE)
  set(MYSQL_LIBRARIES ${MYSQL_LIBRARY} )
else ()
  set(MYSQL_FOUND FALSE)
  set(MYSQL_LIBRARIES)
endif ()

if (MYSQL_FOUND)
  if (NOT MYSQL_FIND_QUIETLY)
    message(STATUS "Found MySQL")
    message(STATUS "MYSQL_LIBRARY = ${MYSQL_LIBRARY}")
    message(STATUS "MYSQL_INCLUDE_DIR = ${MYSQL_INCLUDE_DIR}")
  endif ()
else ()
  if (MYSQL_FIND_REQUIRED)
    message(STATUS "Looked for MySQL libraries named ${MYSQL_NAMES}.")
    message(FATAL_ERROR "Could NOT find MySQL library")
  endif ()
endif ()

mark_as_advanced(
  MYSQL_LIBRARY
  MYSQL_INCLUDE_DIR
)