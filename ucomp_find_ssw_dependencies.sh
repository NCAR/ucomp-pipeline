#!/bin/sh

IDL=idl85

SSW_DIR=${PWD}/ssw
GEN_DIR=${PWD}/gen
LIB_DIR=${PWD}/lib
SRC_DIR=${PWD}/src

FULL_SSW_DIR=/hao/contrib/ssw

UCOMP_PATH=+${SRC_DIR}:${SSW_DIR}:${GEN_DIR}:+${LIB_DIR}:"<IDL_DEFAULT>"
SSW_DEP_PATH="<IDL_DEFAULT>":${UCOMP_PATH}:+${FULL_SSW_DIR}

ROUTINES_FILE=ssw/ROUTINES

echo "Find ROUTINES..."
find src -name '*.pro' -exec basename {} .pro \; > ${ROUTINES_FILE}
find gen -name '*.pro' -exec basename {} .pro \; >> ${ROUTINES_FILE}
find lib -name '*.pro' -exec basename {} .pro \; >> ${ROUTINES_FILE}

echo "Starting IDL..."
${IDL} -IDL_STARTUP "" -IDL_PATH ${SSW_DEP_PATH} -e "ucomp_find_ssw_dependencies, '${ROUTINES_FILE}', '${FULL_SSW_DIR}'" 2> /dev/null
