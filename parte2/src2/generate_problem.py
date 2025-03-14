#!/usr/bin/env python3
"""
Generador de problemas PDDL para el dominio de drones (dominio-drones-parte-2).
Este script crea un archivo .pddl con la instancia solicitada.
Ejemplo de uso:
  python generate_problem.py --drones 1 --containers 1 --locations 10 --persons 10 --crates 10 --goals 5 --output problemasGenerados
"""

import random
import math
import os
import sys
import argparse

# Tipos de contenido que manejan las cajas
content_types = ["comida", "medicina"]

def distance(location_coords, location_num1, location_num2):
    """
    Distancia euclidiana entre dos localizaciones.
    """
    x1 = location_coords[location_num1][0]
    y1 = location_coords[location_num1][1]
    x2 = location_coords[location_num2][0]
    y2 = location_coords[location_num2][1]
    return math.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2)

def flight_cost(location_coords, location_num1, location_num2):
    """
    Costo entero de vuelo (distancia + 1).
    """
    return int(distance(location_coords, location_num1, location_num2)) + 1

def setup_content_types(options):
    """
    Asigna aleatoriamente cuántas cajas tendrán cada tipo de contenido.
    Garantiza que al menos 1 caja de cada tipo esté presente.
    """
    while True:
        num_crates_with_contents = []
        crates_left = options.crates
        for x in range(len(content_types) - 1):
            types_after_this = len(content_types) - x - 1
            max_now = crates_left - types_after_this
            num = random.randint(1, max_now)
            num_crates_with_contents.append(num)
            crates_left -= num

        # Agrega las cajas que falten al último tipo
        num_crates_with_contents.append(crates_left)

        # Calcula máximo número de metas factibles
        maxgoals = sum(min(num_crates, options.persons) 
                       for num_crates in num_crates_with_contents)

        # Chequear si el random soporta el número de goals que queremos
        if options.goals <= maxgoals:
            break

    print("\nTipos de contenido y cantidades:")
    for x, tipo in enumerate(content_types):
        print(f"{tipo}\t {num_crates_with_contents[x]}")

    crates_with_contents = []
    counter = 1
    for x in range(len(content_types)):
        crates = []
        for y in range(num_crates_with_contents[x]):
            crates.append("caja" + str(counter))
            counter += 1
        crates_with_contents.append(crates)

    return crates_with_contents

def setup_location_coords(options):
    """
    Asigna coordenadas (x, y) a cada localización,
    la primera es el depósito (0,0).
    """
    location_coords = [(0, 0)]  # Depósito
    for _ in range(1, options.locations + 1):
        location_coords.append((random.randint(1, 35), random.randint(1, 35)))

    print("Coordenadas generadas:", location_coords)
    return location_coords

def setup_person_needs(options, crates_with_contents):
    """
    Asigna metas (necesidades) a las personas.
    need[persona][contenido] -> True si la persona X necesita el contenido Y.
    """
    need = [[False for _ in range(len(content_types))] 
            for _ in range(options.persons)]
    goals_per_contents = [0 for _ in range(len(content_types))]

    for _ in range(options.goals):
        while True:
            rand_person = random.randint(0, options.persons - 1)
            rand_content = random.randint(0, len(content_types) - 1)
            # Si podemos aún asignar esa necesidad (hay cajas y no asignada ya)
            if (goals_per_contents[rand_content] < len(crates_with_contents[rand_content])
                    and not need[rand_person][rand_content]):
                need[rand_person][rand_content] = True
                goals_per_contents[rand_content] += 1
                break
    return need

def main():
    parser = argparse.ArgumentParser(
        description='Generador de problemas para dominio-drones-parte-2'
    )
    parser.add_argument('--drones', type=int, required=True)
    parser.add_argument('--containers', type=int, required=True)
    parser.add_argument('--locations', type=int, required=True,
                        help='Número de localizaciones (sin contar el depósito)')
    parser.add_argument('--persons', type=int, required=True,
                        help='Número de personas')
    parser.add_argument('--crates', type=int, required=True,
                        help='Número total de cajas')
    parser.add_argument('--goals', type=int, required=True,
                        help='Número de metas (cajas asignadas en total)')
    parser.add_argument('--output', default='problemasGenerados',
                        help='Directorio donde se genera el problema')
    args = parser.parse_args()

    # Validaciones
    if args.goals > args.crates:
        print("No se puede tener más metas que cajas.")
        sys.exit(1)

    if len(content_types) > args.crates:
        print("No se pueden tener más tipos de contenido que cajas:", content_types)
        sys.exit(1)

    if args.goals > len(content_types) * args.persons:
        print(f"No se pueden asignar {args.goals} metas a {args.persons} personas "
              f"si solo hay {len(content_types)} tipos de contenido.")
        sys.exit(1)

    print(f"Drones: {args.drones}")
    print(f"Contenedores: {args.containers}")
    print(f"Localizaciones adicionales: {args.locations}")
    print(f"Personas: {args.persons}")
    print(f"Cajas: {args.crates}")
    print(f"Metas: {args.goals}")
    print(f"Directorio de salida: {args.output}")

    # Crear directorio de salida si no existe
    if not os.path.exists(args.output):
        os.makedirs(args.output)
        print("Directorio creado:", args.output)

    # Lista de objetos
    drone = [f"dron{i+1}" for i in range(args.drones)]
    location = ["deposito"] + [f"loc{i+1}" for i in range(args.locations)]
    person = [f"pers{i+1}" for i in range(args.persons)]
    crate = [f"caja{i+1}" for i in range(args.crates)]
    containers = [f"k{i+1}" for i in range(args.containers)]

    # Configurar contenido de cajas
    crates_with_contents = setup_content_types(args)
    # Coordenadas de localizaciones
    location_coords = setup_location_coords(args)
    # Necesidades de personas
    need = setup_person_needs(args, crates_with_contents)

    # Nombre del problema
    problem_name = (f"drone_problem_d{args.drones}_l{args.locations}"
                    f"_p{args.persons}_c{args.crates}_g{args.goals}"
                    f"_ct{len(content_types)}")

    output_file = os.path.join(args.output, problem_name + ".pddl")

    # Construimos el archivo .pddl
    with open(output_file, 'w') as f:
        # Encabezado
        f.write(f"(define (problem {problem_name})\n")
        # IMPORTANTE: el dominio debe coincidir con la definición en tu dominio PDDL
        f.write("(:domain dominio-drones-parte-2)\n\n")

        # Objetos
        f.write("(:objects\n")
        f.write("  " + " ".join(drone) + " - dron\n")
        f.write("  " + " ".join(location) + " - localizacion\n")
        f.write("  " + " ".join(crate) + " - caja\n")
        f.write("  " + " ".join(content_types) + " - contenido\n")
        f.write("  " + " ".join(person) + " - persona\n")
        f.write("  " + " ".join(containers) + " - contenedor\n")
        f.write("  n0 n1 n2 n3 n4 - num\n")
        f.write(")\n\n")

        # Init
        f.write("(:init\n")

        # Drones
        for d in drone:
            f.write(f"  (dron-en {d} deposito)\n")
            f.write(f"  (dron-libre {d})\n")
            f.write(f"  (dron-sin-caja {d})\n\n")

        f.write("  (en-deposito deposito)\n\n")

        # Contenedores
        for c in containers:
            f.write(f"  (contenedor-libre {c})\n")
        f.write("\n")

        # Cajas con contenido
        for c in crates_with_contents[0]:
            f.write(f"  (caja-en {c} deposito) (caja-libre {c}) (contiene {c} comida)\n")
        f.write("\n")
        for c in crates_with_contents[1]:
            f.write(f"  (caja-en {c} deposito) (caja-libre {c}) (contiene {c} medicina)\n")
        f.write("\n")

        # Personas y sus necesidades
        for i, p_need in enumerate(need):
            # La persona pers{i+1} está en loc{i+1} (asociamos persona i a loc i)
            f.write(f"  (persona-en pers{i+1} loc{i+1})")
            if p_need[0]:
                f.write(f" (necesita pers{i+1} comida)")
            if p_need[1]:
                f.write(f" (necesita pers{i+1} medicina)")
            f.write("\n")
        f.write("\n")

        # Costos de vuelo
        for i in range(len(location_coords)):
            for j in range(len(location_coords)):
                if i != j:
                    loc_i = "deposito" if i == 0 else f"loc{i}"
                    loc_j = "deposito" if j == 0 else f"loc{j}"
                    cost = flight_cost(location_coords, i, j)
                    f.write(f"  (= (fly-cost {loc_i} {loc_j}) {cost})\n")
        f.write("\n")

        # Contenedor con 5 "espacios" (n0..n4)
        for c in containers:
            f.write(f"  (cajas-en-contenedor {c} n0)\n")
        f.write("\n")
        f.write("  (cero n0)\n  (siguiente n0 n1)\n  (siguiente n1 n2)\n"
                "  (siguiente n2 n3)\n  (siguiente n3 n4)\n")

        # Coste total inicial
        f.write("  (= (total-cost) 0)\n")
        f.write(")\n\n")

        # Goals
        f.write("(:goal (and\n")

        # Todos los drones vuelven al deposito
        for d in drone:
            f.write(f"  (dron-en {d} deposito)\n")

        # Metas de que cada persona reciba su contenido
        for x, p_need in enumerate(need):
            for y, needed in enumerate(p_need):
                if needed:
                    f.write(f"  (tiene pers{x+1} {content_types[y]})\n")

        f.write("))\n")
        f.write("(:metric minimize (total-cost))\n")
        f.write(")\n")

    print(f"\nProblema generado en: {output_file}")

if __name__ == '__main__':
    main()