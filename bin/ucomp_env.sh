#!/bin/sh

# This script launches IDL to run interactively with the same environment that
# is used for the script launching processes.

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

if [[ $# -gt 0 ]]; then
  source ${BIN_DIR}/ucomp_parse_args.sh
  echo "ucomp_eod_wrapper, '${DATE}', '${CONFIG}'"
  echo "ucomp_reprocess_wrapper, '${DATE}', '${CONFIG}'"
fi

source ${BIN_DIR}/ucomp_include.sh

${IDL} -quiet \
    -IDL_QUIET 1 \
    -IDL_STARTUP "" \
    -IDL_PATH ${UCOMP_PATH} \
    -IDL_DLM_PATH ${UCOMP_DLM_PATH}
