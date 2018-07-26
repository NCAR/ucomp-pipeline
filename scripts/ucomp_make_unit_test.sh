#!/bin/sh

DIR=$(dirname $0)
ROUTINE_NAME=$1

TEMPLATE=${DIR}/test_template.tt

cat ${TEMPLATE} | sed -e s/NAME/${ROUTINE_NAME}/g > ${ROUTINE_NAME}_ut__define.pro
