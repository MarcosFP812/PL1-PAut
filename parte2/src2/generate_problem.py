#!/usr/bin/env python3
# coding: utf-8

"""
Generador de problemas para 'dominio-drones-parte2.pddl' (Parte 2).
Incluye:
  - Un dron
  - (opcional) varios contenedores
  - localizaciones
  - personas con necesidades
  - cajas y contenidos
  - cost modelado con fly-cost

Se usan objetos n0..n4 para la capacidad (transportador de max 4 cajas).
"""

import random
import math
import os
import sys
import argparse

# Tipos de contenido manejados
CONTENT_TYPES = ["comida", "medicina"]

def distance(coords, i, j):
    """ Distancia euclidiana entre coords[i], coords[j]. """
    x1, y1 = coords[i]
    x2, y2 = coords[j]
    return math.sqrt((x1 - x2)**2 + (y1 - y2)**2)

def flight_cost(coords, i, j):
    """ Coste entero de volar entre i->j. """
    return int(distance(coords, i, j)) + 1

def main():
    parser = argparse.ArgumentParser(description="Generador de problemas para dominio-drones-parte2")
    parser.add_argument("--drones", type=int, default=1, help="Cantidad de drones (normalmente 1)")
    parser.add_argument("--containers", type=int, default=1, help="Cantidad de contenedores (normalmente 1)")
    parser.add_argument("--locations", type=int, default=5, help="Número de localizaciones extra (sin contar depósito)")
    parser.add_argument("--persons", type=int, default=5, help="Número de personas")
    parser.add_argument("--crates", type=int, default=5, help="Número de cajas totales")
    parser.add_argument("--goals", type=int, default=3, help="Número de necesidades totales (suma de todos los contenidos)")
    parser.add_argument("--output", default="problemasGenerados", help="Directorio de salida")
    args = parser.parse_args()

    # Validaciones
    if args.goals > args.crates:
        print("No puede haber más metas que cajas.")
        sys.exit(1)
    if len(CONTENT_TYPES) > args.crates:
        print("No puede haber más tipos de contenido que cajas.")
        sys.exit(1)
    if args.goals > len(CONTENT_TYPES) * args.persons:
        print("Demasiados goals para la cantidad de personas y tipos de contenido.")
        sys.exit(1)

    # Mensajes de depuración
    print("Drones:", args.drones)
    print("Contenedores:", args.containers)
    print("Locations (sin contar depósito):", args.locations)
    print("Persons:", args.persons)
    print("Crates:", args.crates)
    print("Goals:", args.goals)
    print("Output path:", args.output)

    # Crear directorio si no existe
    if not os.path.exists(args.output):
        os.makedirs(args.output)

    # Objetos
    drone = [f"dron{i+1}" for i in range(args.drones)]
    container = [f"k{i+1}" for i in range(args.containers)]
    location = ["deposito"] + [f"loc{i+1}" for i in range(args.locations)]
    person = [f"pers{i+1}" for i in range(args.persons)]
    crate = [f"caja{i+1}" for i in range(args.crates)]

    # Generar coordenadas: la 0 es (0,0) => depósito
    coords = [(0,0)]
    for _ in range(1, args.locations + 1):
        coords.append((random.randint(0,35), random.randint(0,35)))

    # Repartir contenido de las cajas
    # Ej: crates_with_contents[0] son las cajas con "comida"
    #     crates_with_contents[1] son las cajas con "medicina"
    def setup_content_types(crates_total, persons, goals):
        """ Asignar aleatoriamente cuántas cajas de cada contenido. """
        while True:
            num_left = crates_total
            amounts = []
            for i in range(len(CONTENT_TYPES)-1):
                max_now = num_left - (len(CONTENT_TYPES)-(i+1))
                r = random.randint(1, max_now)
                amounts.append(r)
                num_left -= r
            # Ultimo tipo
            amounts.append(num_left)

            # Chequear si con ese reparto se puede cumplir #goals
            # en <= persons
            max_goals = sum(min(cnt, persons) for cnt in amounts)
            if goals <= max_goals:
                return amounts

    amounts = setup_content_types(args.crates, args.persons, args.goals)
    crates_with_contents = []
    cindex = 0
    for i, amt in enumerate(amounts):
        subset = []
        for _ in range(amt):
            cindex += 1
            subset.append(f"caja{cindex}")
        crates_with_contents.append(subset)

    # Necesidades de personas
    # need[pers_i][content_j] => bool
    need = [[False]*len(CONTENT_TYPES) for _ in range(args.persons)]
    goals_per_type = [0]*len(CONTENT_TYPES)
    for _ in range(args.goals):
        while True:
            rp = random.randint(0, args.persons-1)
            rc = random.randint(0, len(CONTENT_TYPES)-1)
            # Si aún hay cajas de ese type (goals_per_type[rc] < len(subset))
            if goals_per_type[rc] < len(crates_with_contents[rc]) and not need[rp][rc]:
                need[rp][rc] = True
                goals_per_type[rc] += 1
                break

    # Nombre del problema
    problem_name = f"drone_problem_d{args.drones}_l{args.locations}_p{args.persons}_c{args.crates}_g{args.goals}_ct{len(CONTENT_TYPES)}"
    out_file = os.path.join(args.output, problem_name+".pddl")

    with open(out_file, "w") as f:
        # Encabezado
        f.write(f"(define (problem {problem_name})\n")
        f.write("(:domain dominio-drones-2)\n\n")

        # Objetos
        f.write("(:objects\n")
        # drone
        f.write("  " + " ".join(drone) + " - dron\n")
        # container
        f.write("  " + " ".join(container) + " - contenedor\n")
        # location
        f.write("  " + " ".join(location) + " - localizacion\n")
        # crate
        f.write("  " + " ".join(crate) + " - caja\n")
        # content
        f.write("  " + " ".join(CONTENT_TYPES) + " - contenido\n")
        # person
        f.write("  " + " ".join(person) + " - persona\n")
        # num => n0..n4
        f.write("  n0 n1 n2 n3 n4 - num\n")
        f.write(")\n\n")

        # Init
        f.write("(:init\n")
        # Dron en deposito
        for d in drone:
            f.write(f"  (dron-en {d} deposito)\n")
            f.write(f"  (dron-libre {d})\n")
            f.write(f"  (dron-sin-caja {d})\n\n")
          
        # Establece el deposito como localización inicial
        f.write("    (en-deposito deposito)\n")
      
        # Contenedores en depósito, libres
        for k in container:
            f.write(f"  (contenedor-en {k} deposito)\n")
            f.write(f"  (contenedor-libre {k})\n")
            # Capacidad inicial = n0 => 0
            f.write(f"  (cajas-en-contenedor {k} n0)\n\n")

        # Cajas en depósito
        for i, group in enumerate(crates_with_contents):
            cont_type = CONTENT_TYPES[i]
            for c in group:
                f.write(f"  (caja-en {c} deposito)\n")
                f.write(f"  (caja-libre {c})\n")
                f.write(f"  (contiene {c} {cont_type})\n")
            f.write("\n")

        # Personas, en loc i+1 (mod if out of range)
        for i, p in enumerate(person):
            loc_index = (i % args.locations) + 1
            locname = f"loc{loc_index}"
            f.write(f"  (persona-en {p} {locname})\n")
            for ct_i, needed in enumerate(need[i]):
                if needed:
                    f.write(f"  (necesita {p} {CONTENT_TYPES[ct_i]})\n")
            f.write("\n")

        # Distancias => (fly-cost loc_i loc_j)
        for i in range(len(coords)):
            for j in range(len(coords)):
                costval = flight_cost(coords, i, j)
                f.write(f"  (= (fly-cost {location[i]} {location[j]}) {costval})\n")

        # Relación siguiente n0->n1->n2->n3->n4
        f.write("\n  (cero n0)\n")
        f.write("  (siguiente n0 n1)\n")
        f.write("  (siguiente n1 n2)\n")
        f.write("  (siguiente n2 n3)\n")
        f.write("  (siguiente n3 n4)\n")

        # total-cost = 0
        f.write("  (= (total-cost) 0)\n")

        f.write(")\n\n")

        # Goal
        f.write("(:goal (and\n")
        # dron en deposito al final (opcional)
        for d in drone:
            f.write(f"  (dron-en {d} deposito)\n")
        # que cada persona reciba lo que necesita
        for i, p in enumerate(person):
            for ct_i, needed in enumerate(need[i]):
                if needed:
                    f.write(f"  (tiene {p} {CONTENT_TYPES[ct_i]})\n")
        f.write("))\n\n")

        # Minimizar
        f.write("(:metric minimize (total-cost))\n")
        f.write(")\n")

    print(f"Problema generado en: {out_file}")


if __name__ == "__main__":
    main()
