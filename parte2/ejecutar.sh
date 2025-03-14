python3 src/test_planiffiers.py \
    --planner 'seq-sat-fdss-2' \
    --domain 'pddl/dominio-drones-parte-2.pddl' \
    --step-size 5 \
    --start 2 \
    --max-size 1000 \
    --timeout 60

# downward: lama-first, seq-sat-fd-autotune-2, seq-sat-fdss-2, seq-opt-lmcut, seq-opt-bjolp, seq-opt-fdss-2
# planificadores/metricff