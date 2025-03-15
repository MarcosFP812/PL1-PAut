#!/usr/bin/env python3
import random
import math
import os
import sys
from optparse import OptionParser

########################################################################################
# Ajustado para un dominio con transportadores numéricos y costes de acción
# Parte 2 de la práctica de planificación.
########################################################################################

content_types = ["comida", "medicina"]

def distance(location_coords, location_num1, location_num2):
    x1 = location_coords[location_num1][0]
    y1 = location_coords[location_num1][1]
    x2 = location_coords[location_num2][0]
    y2 = location_coords[location_num2][1]
    return math.sqrt((x1 - x2)**2 + (y1 - y2)**2)

def flight_cost(location_coords, location_num1, location_num2):
    # Coste = distancia entera + 1
    return int(distance(location_coords, location_num1, location_num2)) + 1

def setup_content_types(options):
    # Reparto aleatorio de cuántas cajas hay de cada contenido
    while True:
        num_crates_with_contents = []
        crates_left = options.crates
        for x in range(len(content_types) - 1):
            types_after_this = len(content_types) - x - 1
            max_now = crates_left - types_after_this
            num = random.randint(1, max_now)
            num_crates_with_contents.append(num)
            crates_left -= num
        # Ultimo tipo se queda con lo que sobra
        num_crates_with_contents.append(crates_left)

        maxgoals = sum(min(n, options.persons) for n in num_crates_with_contents)
        if options.goals <= maxgoals:
            break

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
    # La primera ubicación (0) es el "deposito"
    location_coords = [(0, 0)]
    for x in range(1, options.locations + 1):
        location_coords.append((random.randint(1, 35), random.randint(1, 35)))
    return location_coords

def setup_person_needs(options, crates_with_contents):
    need = [[False for i in range(len(content_types))] for j in range(options.persons)]
    goals_per_contents = [0 for i in range(len(content_types))]

    for _ in range(options.goals):
        generated = False
        while not generated:
            rand_person = random.randint(0, options.persons - 1)
            rand_content = random.randint(0, len(content_types) - 1)
            if (goals_per_contents[rand_content] < len(crates_with_contents[rand_content])
                and not need[rand_person][rand_content]):
                need[rand_person][rand_content] = True
                goals_per_contents[rand_content] += 1
                generated = True

    return need

def main():
    parser = OptionParser()
    parser.add_option('-d', '--drones', type=int, dest='drones')
    parser.add_option('-r', '--containers', type=int, dest='containers')
    parser.add_option('-l', '--locations', type=int, dest='locations')
    parser.add_option('-p', '--persons', type=int, dest='persons')
    parser.add_option('-c', '--crates', type=int, dest='crates')
    parser.add_option('-g', '--goals', type=int, dest='goals')
    parser.add_option('-o', '--output', dest='output', default='problemasGenerados')

    (options, args) = parser.parse_args()

    # Validaciones mínimas
    if not options.drones or not options.containers or not options.locations \
       or not options.persons or not options.crates or not options.goals:
        print("Faltan parámetros. Usa --help para ver opciones.")
        sys.exit(1)

    if options.goals > options.crates:
        print("No puede haber más objetivos que cajas.")
        sys.exit(1)
    if len(content_types) > options.crates:
        print("No puede haber más tipos de contenido que cajas.")
        sys.exit(1)
    if options.goals > len(content_types) * options.persons:
        print("Demasiados goals para la cantidad de personas y tipos de contenido.")
        sys.exit(1)

    # Mostrar info
    print("Drones:", options.drones)
    print("Containers:", options.containers)
    print("Locations:", options.locations)
    print("Persons:", options.persons)
    print("Crates:", options.crates)
    print("Goals:", options.goals)
    print("Output path:", options.output)

    # Crear el directorio de salida si no existe
    if not os.path.exists(options.output):
        os.makedirs(options.output)

    # Construir los nombres de objetos
    drones = ["dron"+str(i+1) for i in range(options.drones)]
    people = ["pers"+str(i+1) for i in range(options.persons)]
    crates = ["caja"+str(i+1) for i in range(options.crates)]
    containers = ["k"+str(i+1) for i in range(options.containers)]
    locations = ["deposito"] + ["loc"+str(i+1) for i in range(options.locations)]

    # Elegir cuántas cajas de cada tipo
    crates_with_contents = setup_content_types(options)
    # Coordenadas de cada ubicación
    location_coords = setup_location_coords(options)
    # Matriz de necesidades
    need = setup_person_needs(options, crates_with_contents)

    # Crear nombre de problema
    problem_name = "drone_problem_d{}_l{}_p{}_c{}_g{}_ct{}".format(
        options.drones, options.locations, options.persons,
        options.crates, options.goals, len(content_types)
    )

    output_file = os.path.join(options.output, problem_name + ".pddl")
    with open(output_file, "w") as f:
        f.write("(define (problem {})\n".format(problem_name))
        f.write("(:domain dominio-drones-parte2)\n\n")

        # ------------------------------------------------------
        # Objetos
        # ------------------------------------------------------
        f.write("(:objects\n")

        f.write("  ")  # drones
        for d in drones:
            f.write("{} ".format(d))
        f.write("- dron\n")

        f.write("  ")  # locations
        for loc in locations:
            f.write("{} ".format(loc))
        f.write("- localizacion\n")

        f.write("  ")  # crates
        for c in crates:
            f.write("{} ".format(c))
        f.write("- caja\n")

        f.write("  ")  # contenido
        for ct in content_types:
            f.write("{} ".format(ct))
        f.write("- contenido\n")

        f.write("  ")  # personas
        for pp in people:
            f.write("{} ".format(pp))
        f.write("- persona\n")

        f.write("  ")  # contenedores
        for k in containers:
            f.write("{} ".format(k))
        f.write("- contenedor\n")

        # Numeros para capacidad 0..4
        f.write("  n0 n1 n2 n3 n4 - num\n")

        f.write(")\n\n")

        # ------------------------------------------------------
        # Init
        # ------------------------------------------------------
        f.write("(:init\n")

        # 1) Estados iniciales del dron
        for d in drones:
            f.write("  (dron-en {} deposito)\n".format(d))
            f.write("  (dron-libre {})\n".format(d))
            f.write("  (dron-sin-caja {})\n".format(d))
            f.write("\n")

        # 2) Contenedores en el depósito y vacíos (cajas-en-contenedor k n0)
        for k in containers:
            f.write("  (contenedor-en {} deposito)\n".format(k))
            f.write("  (contenedor-libre {})\n".format(k))
            f.write("  (cajas-en-contenedor {} n0)\n".format(k))

        # 3) Cajas en el depósito, libres
        for i, group in enumerate(crates_with_contents):
            for c in group:
                f.write("  (caja-en {} deposito)\n".format(c))
                f.write("  (caja-libre {})\n".format(c))
                f.write("  (contiene {} {})\n".format(c, content_types[i]))
            f.write("\n")

        # 4) Personas y necesidades
        #   Asignamos persona-en persX locX+1 (salvo que quieras aleatorio)
        #   y (necesita persX contenido) según la matriz need
        for i, p in enumerate(people):
            # Para simplicidad, que cada persona esté en loc i+1 (si i < #locations)
            # Si tienes más personas que localizaciones, tendrás que hacer algo más aleatorio
            loc_index = (i % (options.locations)) + 1
            f.write("  (persona-en {} loc{})\n".format(p, loc_index))

            for cont_i, needed in enumerate(need[i]):
                if needed:
                    f.write("  (necesita {} {})\n".format(p, content_types[cont_i]))
            f.write("\n")

        # 5) Definir los costes de vuelo (fly-cost locA locB)
        for i in range(len(location_coords)):
            for j in range(len(location_coords)):
                if i != j:
                    cost_value = flight_cost(location_coords, i, j)
                    loc_i = locations[i]
                    loc_j = locations[j]
                    f.write("  (= (fly-cost {} {}) {})\n".format(loc_i, loc_j, cost_value))

        # 6) Relación siguiente para n0->n1->n2->n3->n4
        f.write("\n  (cero n0)\n")
        f.write("  (siguiente n0 n1)\n")
        f.write("  (siguiente n1 n2)\n")
        f.write("  (siguiente n2 n3)\n")
        f.write("  (siguiente n3 n4)\n")

        # 7) Iniciar total-cost a 0
        f.write("  (= (total-cost) 0)\n")

        f.write(")\n\n")

        # ------------------------------------------------------
        # Goal
        # ------------------------------------------------------
        f.write("(:goal (and\n")
        # a) dron(es) de vuelta al deposito (opcional)
        for d in drones:
            f.write("  (dron-en {} deposito)\n".format(d))

        # b) cada persona tenga lo que necesita
        for i, p in enumerate(people):
            for cont_i, needed in enumerate(need[i]):
                if needed:
                    f.write("  (tiene {} {})\n".format(p, content_types[cont_i]))
        f.write("))\n\n")

        # ------------------------------------------------------
        # Métrica: minimizar coste total
        # ------------------------------------------------------
        f.write("(:metric minimize (total-cost))\n")

        f.write(")\n")  # Cierre define problem

    print("Problema generado en:", output_file)


if __name__ == "__main__":
    main()