#!/bin/bash

## Script used to disconnect attached usb ports from existing VMs (if there are any) and 
## connect all available iPhone devices to available VMs
## This script should be executed before running vagrant up/provision

CONNECTED_DEVICES_TO_VM=`/usr/local/bin/prlsrvctl usb list | grep iPhone | grep {.*} | grep -o "'.*'" | sed "s/'//g"`

for CONNECTED_DEVICE in $CONNECTED_DEVICES_TO_VM; do
  echo "Delete connection to vm from device ${CONNECTED_DEVICE}..."
  device_disconnected=`/usr/local/bin/prlsrvctl usb del ${CONNECTED_DEVICE}`
  if [[ $device_disconnected == "The Server has been successfully configured." ]]; then
    echo "[SUCCESS] USB device disconnected from VM successfully!"
  else
    echo "[ERROR] USB device was not disconnected from VM successfully!"
    exit 1
  fi
done

VMS=`/usr/local/bin/prlctl list | grep -o {.*}`
DEVICES=`/usr/local/bin/prlsrvctl usb list | grep iPhone | grep -o "'.*'" | sed "s/'//g"`

vm_array=()
device_array=()

for VM in $VMS; do
  echo "VM found with id: ${VM}"
  vm_array+=($VM)
done

for DEVICE in $DEVICES; do
  echo "Device found: ${DEVICE}"
  device_array+=($DEVICE)
done

for ((i=0; i < ${#vm_array[@]}; i++)); do
  echo "VM is: ${vm_array[i]}"
  echo "/usr/local/bin/prlsrvctl usb set ${device_array[i]} ${vm_array[i]}"

  usb_set=`/usr/local/bin/prlsrvctl usb set ${device_array[i]} ${vm_array[i]}`
  if [[ $usb_set == "The Server has been successfully configured." ]]; then
    echo "[SUCCESS] USB set ${device_array[i]} for VM ${vm_array[i]}"
  else
    echo "[ERROR] Unable to set USB ${device_array[i]} for VM ${vm_array[i]}"
    exit 1
  fi
done
