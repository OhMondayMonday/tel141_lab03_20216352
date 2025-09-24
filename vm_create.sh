#!/bin/bash

# Script para crear una VM usando la imagen base cirros-0.5.1-x86_64-disk.img y conectar su TAP al OVS con VLAN.
# Uso: ./vm_create.sh <nombreVM> <nombreOvS> <VLAN_ID> <VNC_PORT>
# Ejemplo: ./vm_create.sh VM1 br-int 100 5901

if [ "$#" -ne 4 ]; then
  echo "Uso: $0 <nombreVM> <nombreOvS> <VLAN_ID> <VNC_PORT>"
  exit 1
fi

NOMBRE_VM="$1"
NOMBRE_OVS="$2"
VLAN_ID="$3"
VNC_PORT="$4"

TAP_IF="tap_${NOMBRE_VM}"

# Ruta a la imagen base Cirros (ajusta si usas otra ubicación)
DISK_PATH="/var/lib/libvirt/images/cirros-0.5.1-x86_64-disk.img"

if [ ! -f "$DISK_PATH" ]; then
  echo "ERROR: No se encuentra la imagen base en $DISK_PATH"
  exit 2
fi

# Crear interfaz TAP para la VM
sudo ip tuntap add dev $TAP_IF mode tap
sudo ip link set $TAP_IF up

# Conectar TAP al OVS y asignar VLAN
sudo ovs-vsctl add-port $NOMBRE_OVS $TAP_IF
sudo ovs-vsctl set port $TAP_IF tag=$VLAN_ID

# Crear la VM usando la imagen base Cirros
sudo virt-install \
  --name "$NOMBRE_VM" \
  --ram 256 \
  --vcpus 1 \
  --disk path="$DISK_PATH",format=qcow2,readonly=on \
  --import \
  --os-type=linux \
  --network tap,ifname=$TAP_IF,script=no,downscript=no \
  --graphics vnc,port=$VNC_PORT,listen=0.0.0.0 \
  --noautoconsole

echo "VM $NOMBRE_VM creada y conectada a $NOMBRE_OVS (VLAN $VLAN_ID, VNC $VNC_PORT, usando imagen Cirros)"
