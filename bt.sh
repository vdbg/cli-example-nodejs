#!/bin/bash

declare -A devices
declare -A deviceStatuses

config_file="bt.config"
stop_file="bt.stop"

[ -f "$config_file" ] || { echo "$config_file file not found."; exit 1; }

. "$config_file"

[[ ${#devices[@]} -gt 0 ]] || { echo "No devices defined."; exit 1; }
[ -n "$SMARTTHINGS_CLI_TOKEN" ] || { echo "SMARTTHINGS_CLI_TOKEN is not set."; exit 1; }

export SMARTTHINGS_CLI_TOKEN

probe_bt () {
  declare uuid_of_device=$3
  declare mac_of_device=$2
  declare name_of_device=$1

  echo "Probing device $name_of_device with mac $mac_of_device and uuid $uuid_of_device ..."

  cmdout=$(hcitool cc $mac_of_device \
           && hcitool auth $mac_of_device \
           && hcitool rssi $mac_of_device \
           && hcitool dc $mac_of_device )

  echo "Output: $cmdout"

  btcurrent=-1
  btcurrent=$(echo $cmdout | grep -c "RSSI return value") 2> /dev/null
  rssi=$(echo $cmdout | sed -e 's/RSSI return value: //g')

  if [ $btcurrent = 1 ]; then
    echo "Device connected with RSSI: $rssi"
    btcurrent="turnonbyid"
  else
    echo "Device not connected!"
    btcurrent="turnoffbyid"
  fi

  if [ "${deviceStatuses[$uuid_of_device]}" != "$btcurrent" ]; then
    echo "Updating smarthome status..."
    echo sthelper $btcurrent $uuid_of_device
    sthelper $btcurrent $uuid_of_device
    if [ $? = 0 ]; then
      deviceStatuses[$uuid_of_device]=$btcurrent 
    fi
  fi
}

probe_bts() {
  echo "Probing devices: $@"
  for device in "$@"; do
    probe_bt "$device" ${devices[$device]}
  done
}

while :
do

  if [ $# -eq 0 ]; then
    echo "Probing all devices"
    probe_bts "${!devices[@]}"
  else
    echo "Probing selected devices"
    probe_bts "$@"
  fi

  [ -f "$stop_file" ] && { echo "$stop_file found; exiting."; exit 0; }
  sleep 5m
  [ -f "$stop_file" ] && { echo "$stop_file found; exiting."; exit 0; }
done
