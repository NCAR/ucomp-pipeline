#!/bin/sh

# This script launches IDL for the realtime pipeline to process a part of a day.

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

source ${BIN_DIR}/ucomp_include.sh

# skip first two lines of output (IDL license info)
${IDL} -quiet \
    -IDL_QUIET 1 \
    -IDL_STARTUP "" \
    -IDL_PATH ${UCOMP_PATH} \
    -IDL_DLM_PATH ${UCOMP_DLM_PATH} \
    -e "ucomp_realtime, '${DATE}', '${CONFIG}'" \
    2>&1 | tail -n +3