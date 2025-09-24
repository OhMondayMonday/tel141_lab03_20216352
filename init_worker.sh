#!/bin/bash

# ./init_worker.sh <nombreOvS> <interface1> [<interface2> ...]

if [ "$#" -lt 2 ]; then
  echo "Uso: $0 <nombreOvS> <interface1> [<interface2> ...]" 
  exit 1
fi

NOMBRE_OVS="$1"
shift
INTERFACES=("$@")

# Crear el bridge si no existe
if ! sudo ovs-vsctl br-exists "$NOMBRE_OVS"; then
  echo "Creando bridge $NOMBRE_OVS..."
  sudo ovs-vsctl add-br "$NOMBRE_OVS"
else
  echo "El bridge $NOMBRE_OVS ya existe."
fi

# Conectar interfaces al bridge
for iface in "${INTERFACES[@]}"; do
  if sudo ovs-vsctl list-ports "$NOMBRE_OVS" | grep -qw "$iface"; then
    echo "La interfaz $iface ya está conectada a $NOMBRE_OVS."
  else
    echo "Conectando $iface a $NOMBRE_OVS..."
    sudo ovs-vsctl add-port "$NOMBRE_OVS" "$iface"
  fi
done

echo "init_worker.sh finalizado."
