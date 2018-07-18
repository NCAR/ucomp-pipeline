#!/bin/sh

CONFIG=$(basename $1)
TMP_FILENAME=$2
EMAIL=$3

cat ${TMP_FILENAME} | mail -s "Done processing pipeline with ${CONFIG}" -r "$(whoami)@ucar.edu" ${EMAIL}
