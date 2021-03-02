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

# run on a week, starting from 2 days before the current date
START_DATE=$(date +"%Y%m%d" -d "-9 days")
END_DATE=$(date +"%Y%m%d" -d "-2 days")

# find locations relative to this script
SCRIPT_LOC=$(canonicalpath $0)
BIN_DIR=$(dirname ${SCRIPT_LOC})

LOG_FILENAME=/tmp/ucomp-$RANDOM.log

$BIN_DIR/ucomp_validate_dates.sh "$START_DATE-$END_DATE" &> $LOG_FILENAME
N_FAILED_DAYS=$?

if (( N_FAILED_DAYS > 0 )); then
  SUBJECT="UCoMP validation for $START_DATE-$END_DATE ($N_FAILED_DAYS failed days)"
else
  SUBJECT="UCoMP validation for $START_DATE-$END_DATE (success)"
fi

mail -s "$SUBJECT" -r $(whoami)@ucar.edu $(cat ~/.ucomp_notifiers) < $LOG_FILENAME

rm -f $LOG_FILENAME
