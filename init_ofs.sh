#!/bin/bash

# ./init_ofs.sh <nombreOvS> <interface1> [<interface2> ...]

if [ "$#" -lt 2 ]; then
  echo "Uso: $0 <nombreOvS> <interface1> [<interface2> ...]"
  exit 1
fi

NOMBRE_OVS="$1"
shift
INTERFACES=("$@")

for iface in "${INTERFACES[@]}"; do
  echo "Limpiando IP de $iface..."
  sudo ip addr flush dev "$iface"

  if sudo ovs-vsctl list-ports "$NOMBRE_OVS" | grep -qw "$iface"; then
    echo "La interfaz $iface ya está conectada a $NOMBRE_OVS."
  else
    echo "Conectando $iface a $NOMBRE_OVS..."
    sudo ovs-vsctl add-port "$NOMBRE_OVS" "$iface"
  fi
done

echo "init_ofs.sh finalizado."
