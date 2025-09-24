#!/bin/bash

if [ "$#" -ne 4 ]; then
  echo "Uso: $0 <nombreVM> <nombreOvS> <VLAN_ID> <VNC_PORT>"
  exit 1
fi

NOMBRE_VM="$1"
NOMBRE_OVS="$2"
VLAN_ID="$3"
VNC_PORT="$4"

TAP_IF="tap_${NOMBRE_VM}"

sudo ip tuntap add dev $TAP_IF mode tap
sudo ip link set $TAP_IF up

sudo ovs-vsctl add-port $NOMBRE_OVS $TAP_IF
sudo ovs-vsctl set port $TAP_IF tag=$VLAN_ID

DISK_PATH="/var/lib/libvirt/images/${NOMBRE_VM}.qcow2"
if [ ! -f "$DISK_PATH" ]; then
  sudo qemu-img create -f qcow2 "$DISK_PATH" 10G
fi

sudo virt-install \
  --name "$NOMBRE_VM" \
  --ram 1024 \
  --vcpus 1 \
  --disk path="$DISK_PATH",format=qcow2 \
  --import \
  --os-type=linux \
  --network tap,ifname=$TAP_IF,script=no,downscript=no \
  --graphics vnc,port=$VNC_PORT,listen=0.0.0.0 \
  --noautoconsole

echo "VM $NOMBRE_VM creada y conectada a $NOMBRE_OVS (VLAN $VLAN_ID, VNC $VNC_PORT)"
