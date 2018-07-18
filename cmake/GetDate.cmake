# needed for TIMESTAMP sub-command for STRING
cmake_minimum_required(VERSION 2.8.11)

macro(TODAY RESULT)
  string(TIMESTAMP M "%m")
  string(TIMESTAMP D "%d")
  string(TIMESTAMP Y "%y")
  set(${RESULT} "${M}/${D}/${Y}")
endmacro()

macro(LONG_TODAY RESULT)
  set(MONTHS ";Jan;Feb;Mar;Apr;May;Jun;Jul;Aug;Sep;Oct;Nov;Dec")
  set(DAYS_OF_WEEK "Sun;Mon;Tue;Wed;Thu;Fri;Sat")

  string(TIMESTAMP DOW "%w")
  list(GET DAYS_OF_WEEK "${DOW}" DOW)
  string(TIMESTAMP M "%m")
  list(GET MONTHS "${M}" MON)
  string(TIMESTAMP D "%d")
  string(TIMESTAMP TIME "%H:%M:%S")
  string(TIMESTAMP Y "%Y")
  set(${RESULT} "${DOW} ${MON} ${D} ${TIME} ${Y}")
endmacro()