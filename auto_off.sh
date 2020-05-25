#!/bin/bash

config_file="bt.config"

[ -f "$config_file" ] || { echo "$config_file file not found."; exit 1; }

. "$config_file"


[ -n "$SMARTTHINGS_CLI_TOKEN" ] || { echo "SMARTTHINGS_CLI_TOKEN is not set."; exit 1; }
export SMARTTHINGS_CLI_TOKEN

[ -n "$ST_DEVICE_ID" ] || { echo "ST_DEVICE_ID is not set."; exit 1; }


get_st_status () {
  ST_STATUS=unknown
  ST_STATUS=$(sthelper statusvaluebyid $1)
  echo "$2status is: $ST_STATUS"
}

get_st_status $ST_DEVICE_ID "Computer "

if [ "$ST_STATUS" = "off" ]; then
  echo "Shutting down computer!"
  shutdown now
else
  if [ -n "$PROCESSES_TO_KILL" ] && [ -n "$ST_KILLPROCS_ID" ]; then
    get_st_status $ST_KILLPROCS_ID "Processes "
    if [ "$ST_STATUS" = "off" ]; then
      echo "Killing: $PROCESSES_TO_KILL"
      for process in "$PROCESSES_TO_KILL"; do
        killall $process
      done 
    fi
  fi
fi


