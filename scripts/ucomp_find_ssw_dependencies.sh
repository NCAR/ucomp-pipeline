#!/bin/sh

PIPELINE_ROOT=$(dirname $0)/..

SRC_DIR=${PIPELINE_ROOT}/src
SSW_DIR=${PIPELINE_ROOT}/ssw
GEN_DIR=${PIPELINE_ROOT}/gen
LIB_DIR=${PIPELINE_ROOT}/lib

IDL=/opt/share/idl8.6/idl86/bin/idl

FULL_SSW_DIR=/hao/contrib/ssw


UCOMP_PATH=+${SRC_DIR}:${SSW_DIR}:${GEN_DIR}:+${LIB_DIR}:"<IDL_DEFAULT>"

SSW_DEP_PATH="<IDL_DEFAULT>":${UCOMP_PATH}:+${FULL_SSW_DIR}

# find UCoMP src routines
find ${SRC_DIR} -name '*.pro' -exec basename {} .pro \; > ${SSW_DIR}/ROUTINES

# find/add SolarSoft routines
${IDL} -IDL_STARTUP "" \
       -IDL_PATH ${SSW_DEP_PATH} \
       -e "ucomp_find_ssw_dependencies, '${FULL_SSW_DIR}'"

# for some reason, some SolarSoft routines are set to executable
chmod -x ${SSW_DIR}/*.pro
