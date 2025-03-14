#!/bin/bash

# Lista de planificadores "lama-first" "seq-sat-fd-autotune-2" "seq-opt-lmcut" "seq-opt-bjolp" "planificadores/metricff"
planners=("seq-sat-fd-autotune-2" "seq-opt-lmcut" "seq-opt-bjolp" "planificadores/metricff")

# Recorremos cada planner e invocamos el comando python
for planner in "${planners[@]}"; do
    echo "Ejecutando planner: $planner"
    python3 src/test_planiffiers.py \
        --planner "$planner" \
        --domain "pddl/dominio-drones-parte-2.pddl" \
        --start 2 \
        --step-size 5 \
        --max-size 1000 \
        --timeout 60
done
