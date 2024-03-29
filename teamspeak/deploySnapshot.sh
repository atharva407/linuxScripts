#!/bin/bash

set -e
set -u
#set -x

if [ $# -lt 3 -o $# -gt 6 ]; then
  echo "Usage: $0 username password host [query_port=10011] [input_file=snapshot.txt] [virtual server id=1]"
  exit -1
fi

USER="$1"
PASS="$2"
HOST="$3"
PORT="10011"
INPUT_FILE="snapshot.txt"
SID=1
if [ $# -gt 3 ]; then
  PORT="${4}"
fi
if [ $# -gt 4 ]; then
  INPUT_FILE="${5}"
fi
if [ $# -gt 5 ]; then
  SID="${6}"
fi

if [ ! -f ${INPUT_FILE} ]; then
  echo "could not find input file ${INPUT_FILE}, aborting"
  exit -2
fi
( echo "use ${SID}"; echo "login ${USER} ${PASS}"; echo -n "serversnapshotdeploy "; cat ${INPUT_FILE}; echo; echo "quit" ) | nc ${HOST} ${PORT} > snapshot_apply.txt
if [ ! "`cat snapshot_apply.txt | grep "error id=0 msg=ok" | wc -l | sed 's/ .*//'`" = 4 ]; then
  echo "Echo unable to apply the snapshot"
  echo "This is what we got as answer to the commands use, login, serversnapshotdeploy, quit:"
  cat snapshot_apply.txt
  rm snapshot_apply.txt
  exit -3
fi

rm snapshot_apply.txt

echo "Successfully applied snapshot"
