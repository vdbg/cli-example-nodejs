Notifies SmartThings switch devices when a given Bluetooth device is in range

# Prequisites

`sudo apt-get install nodejs npm`


# Identify devices

- `sudo bluetoothctl`
- `scan on`: to see devices. Note the address of the device of interest
-  Optional: for RSSI option (seeing device's strength, a proxy for distance):
  - `advertise on`: so that devices can see you
  - `pair MAC_ADDRESS`: for each device to pair. Alternative is to initiate pairing from target device
    Note: may have to answer code or answer prompts on one or both of devices
  - `advertise off` and `scan off` when done
- `quit`

# Running script

- Edit `bt.config` to add the SmartThings token.
- Create one "Simulated Switch Device" per Bluetooth device on https://account.smartthings.com
- Add one entry in `bt.config` for each one of the Bluetooth devices with the device Bluetooth mac address and the device uuid from SmartThings
- Run `sudo ./bt.sh` to test

