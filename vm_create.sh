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

# Ruta a la imagen base Cirros
DISK_PATH="/var/lib/libvirt/images/cirros-0.5.1-x86_64-disk.img"
if [ ! -f "$DISK_PATH" ]; then
  echo "ERROR: No se encuentra la imagen base en $DISK_PATH"
  exit 2
fi

# Crear interfaz TAP (si no existe)
if ! ip link show "$TAP_IF" &>/dev/null; then
  sudo ip tuntap add dev $TAP_IF mode tap
  sudo ip link set $TAP_IF up
fi

# Conectar TAP al OVS y asignar VLAN
sudo ovs-vsctl --may-exist add-port $NOMBRE_OVS $TAP_IF
sudo ovs-vsctl set port $TAP_IF tag=$VLAN_ID

# Lanzar la VM con QEMU
sudo qemu-system-x86_64 \
  -name "$NOMBRE_VM" \
  -m 256 \
  -smp 1 \
  -hda "$DISK_PATH" \
  -netdev tap,id=net0,ifname=$TAP_IF,script=no,downscript=no \
  -device virtio-net-pci,netdev=net0 \
  -vnc :$((VNC_PORT-5900)) \
  -daemonize

echo "VM $NOMBRE_VM lanzada en QEMU, conectada a $NOMBRE_OVS (VLAN $VLAN_ID, VNC $VNC_PORT)"
