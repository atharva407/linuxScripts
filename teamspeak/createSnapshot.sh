#!/bin/bash

set -e
set -u
#set -x

if [ $# -lt 3 -o $# -gt 6 ]; then
  echo "Usage: $0 username password host [query_port=10011] [output_file=snapshot.txt] [virtual server ID=1]"
  exit -1
fi

USER="$1"
PASS="$2"
HOST="$3"
PORT="$4"
FINAL_FILE="$5"
OUTPUT_FILE="snapshot.txt"
SID=1
if [ $# -gt 3 ]; then
  PORT="${4}"
fi
if [ $# -gt 4 ]; then
  FINAL_FILE="${5}"
fi
if [ $# -gt 5 ]; then
  SID="${6}"
fi

if [ -e ${OUTPUT_FILE} ]; then
  echo "output file alread exists, aborting"
  exit -2
fi
touch "${OUTPUT_FILE}"
( echo "use ${SID}"; echo "login ${USER} ${PASS}"; echo "serversnapshotcreate"; echo "quit" ) | nc ${HOST} ${PORT} | tr -d "\r" | grep . > ${OUTPUT_FILE}

if [ ! "$(wc -l ${OUTPUT_FILE} | sed 's/ .*//')" = "7" ]; then
  echo "Invalid number of lines from snapshot retrieval, aborting"
  echo "View ${OUTPUT_FILE} for details"
  exit -3
fi

line_number=0
while IFS=$'\n' read -r "line"; do
  if [ "$line_number" == "0" ]; then
    if [ ! "$line" = "TS3" ]; then  
      echo "Invalid greeting line, looking for \"TS3\", got ${line}"
	  exit -4
    fi
  elif [ "$line_number" == "1" ]; then
    if [ ! "$line" = 'Welcome to the TeamSpeak 3 ServerQuery interface, type "help" for a list of commands and "help <command>" for information on a specific command.' ]; then
      echo "Invalid greeting line, looking for \"This is the TeamSpeak3 Server Query\"...."
      exit -5
    fi  
  elif [ "$line_number" == "2" ]; then
    if [ ! "$line" = "error id=0 msg=ok" ]; then
      echo "Didnt get error ok on \"use 1\", got ${line}"
      exit -6
    fi
  elif [ "$line_number" == "3" ]; then
    if [ ! "$line" = "error id=0 msg=ok" ]; then
      echo "Didnt get error ok on \"login serveradmin password\", got ${line}"
      exit -7
    fi
  elif [ "$line_number" == "4" ]; then
    echo "$line" > real_${OUTPUT_FILE}
  elif [ "$line_number" == "5" ]; then
    if [ ! "$line" = "error id=0 msg=ok" ]; then
      echo "Didnt get ok on serversnapshotcreate, got ${line}"
      exit -8
    fi
  elif [ "$line_number" == "6" ]; then
    if [ ! "$line" = "error id=0 msg=ok" ]; then
	  echo "Didnt get ok on \"quit\", got ${line}"
	  exit -10
	fi
  else
    echo "snapshot.txt file being written to as we speak? Something is very wrong here..."
	exit -9
  fi
  ((++line_number))
done < "${OUTPUT_FILE}"

mv real_${OUTPUT_FILE} ${FINAL_FILE}

echo "Successfully retrieved the image, it is now in ${FINAL_FILE}"

