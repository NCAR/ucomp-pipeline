#!/bin/sh

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

source ${BIN_DIR}/ucomp_include.sh

DATES=(20210312)
LOG_DIR=/hao/twilight/Data/UCoMP/logs.regression

CONFIG=${PIPE_DIR}/config/ucomp.regression.cfg
STATUS=0
for day in ${DATES[@]}; do
  ${IDL} -quiet -IDL_QUIET 1 -IDL_STARTUP "" \
    -IDL_PATH ${UCOMP_PATH} -IDL_DLM_PATH ${UCOMP_DLM_PATH} \
    -e "ucomp_regression_wrapper, '${day}', '${CONFIG}'" > /dev/null 2>&1
  if [ $? -ne 0 ]; then STATUS=$(( ${STATUS} | $? )); fi
  LOG_FILENAME=${LOG_DIR}/${day}.ucomp.regress.log
  echo ${LOG_FILENAME}
  cat ${LOG_FILENAME}
done

exit ${STATUS}
