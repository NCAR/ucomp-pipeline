#!/bin/sh

# This script launches IDL to run a script (like the realtime or eod processing
# scripts) on a date.

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

# u=rwx,g=rwx,o=rx
umask 0002

# find locations relative to this script
SCRIPT_LOC=$(canonicalpath $0)
BIN_DIR=$(dirname ${SCRIPT_LOC})
PIPE_DIR=$(dirname ${BIN_DIR})

SCRIPT_NAME=$1
shift

source ${BIN_DIR}/ucomp_parse_args.sh
source ${BIN_DIR}/ucomp_include.sh

# skip first two lines of output (IDL license info)
${IDL} -quiet \
    -IDL_QUIET 1 \
    -IDL_STARTUP "" \
    -IDL_PATH ${UCOMP_PATH} \
    -IDL_DLM_PATH ${UCOMP_DLM_PATH} \
    -e "${SCRIPT_NAME}, '${DATE}', '${CONFIG}'" \
    2>&1 | tail -n +3
