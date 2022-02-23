#!/bin/sh

# This script launches IDL to verify that CoMP has run properly on the given
# date(s).

canonicalpath() {
  if [ -d $1 ]; then
    pushd $1 > /dev/null 2>&1
    echo $PWD
  elif [ -f $1 ]; then
    pushd $(dirname $1) > /dev/null 2>&1
    echo $PWD/$(basename $1)
  else
    echo "Invalid path $1"
  fi
  popd > /dev/null 2>&1
}

# find locations relative to this script
SCRIPT_LOC=$(canonicalpath $0)
BIN_DIR=$(dirname ${SCRIPT_LOC})
PIPE_DIR=$(dirname ${BIN_DIR})

source ${BIN_DIR}/ucomp_parse_args.sh
source ${BIN_DIR}/ucomp_include.sh

${IDL} -quiet -IDL_QUIET 1 -IDL_STARTUP "" \
  -IDL_PATH ${UCOMP_PATH} -IDL_DLM_PATH ${UCOMP_DLM_PATH} \
  -e "ucomp_verify_dates, '${DATE}', '${CONFIG}'"

exit $?
