#!/bin/bash

# --- En el nodo OFS central ---
# ./init_ofs.sh br-ofs ens4 ens5 ens6

# --- En cada Worker ---
./init_worker.sh br-int ens4

# --- Crear VMs en cada Worker ---
./vm_create.sh VM1 br-int 100 5901
./vm_create.sh VM2 br-int 200 5902
./vm_create.sh VM3 br-int 300 5903

echo "Topología de Fase 1 desplegada."
