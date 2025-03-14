#!/usr/bin/env python3

########################################################################################
# Problem instance generator skeleton for emergencies drones domain.
# Based on the Linköping University TDDD48 2021 course.
# https://www.ida.liu.se/~TDDD48/labs/2021/lab1/index.en.shtml
#
# You mainly have to change the parts marked as TODO.
#
########################################################################################


from optparse import OptionParser
import random
import math
import os
import sys

########################################################################################
# Hard-coded options
########################################################################################

# Crates will have different contents, such as food and medicine.
# You can change this to generate other contents if you want.

content_types = ["comida", "medicina"]


########################################################################################
# Random seed
########################################################################################

# Set seed to 0 if you want more predictability...
# random.seed(0);

########################################################################################
# Helper functions
########################################################################################

# We associate each location with x/y coordinates.  These coordinates
# won't actually be used explicitly in the domain, but we *will*
# eventually use them implicitly by using *distances* in order to
# calculate flight times.
#
# This function returns the euclidean distance between two locations.
# The locations are given via their integer index.  You won't have to
# use this other than indirectly through the flight cost function.
def distance(location_coords, location_num1, location_num2):
    x1 = location_coords[location_num1][0]
    y1 = location_coords[location_num1][1]
    x2 = location_coords[location_num2][0]
    y2 = location_coords[location_num2][1]
    return math.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2)


# This function returns the action cost of flying between two
# locations supplied by their integer indexes.  You can use this
# function when you extend the problem generator to generate action
# costs.
def flight_cost(location_coords, location_num1, location_num2):
    return int(distance(location_coords, location_num1, location_num2)) + 1


# When you run this script you specify the *total* number of crates
# you want.  The function below determines randomly which crates
# will have a specific type of contents.  crates_with_contents[0]
# is a list of crates containing content_types[0] (in our
# example "food"), and so on.
# Note: Will have at least one crate per type!

def setup_content_types(options):
    while True:
        num_crates_with_contents = []
        crates_left = options.crates
        for x in range(len(content_types) - 1):
            types_after_this = len(content_types) - x - 1
            max_now = crates_left - types_after_this
            # print x, types_after_this, crates_left, len(content_types), max_now
            num = random.randint(1, max_now)
            # print num
            num_crates_with_contents.append(num)
            crates_left -= num
        num_crates_with_contents.append(crates_left)
        # print(num_crates_with_contents)

        # If we have 10 medicine and 4 food, with 7 people,
        # we can support at most 7+4=11 goals.
        maxgoals = sum(min(num_crates, options.persons) for num_crates in num_crates_with_contents)

        # Check if the randomization supports the number of goals we want to generate.
        # Otherwise, try to randomize again.
        if options.goals <= maxgoals:
            # Done
            break

    print()
    print("Types\tQuantities")
    for x in range(len(num_crates_with_contents)):
        if num_crates_with_contents[x] > 0:
            print(content_types[x] + "\t " + str(num_crates_with_contents[x]))

    crates_with_contents = []
    counter = 1
    for x in range(len(content_types)):
        crates = []
        for y in range(num_crates_with_contents[x]):
            crates.append("caja" + str(counter))
            counter += 1
        crates_with_contents.append(crates)

    return crates_with_contents


# This function populates the location_coords list with an X and Y
# coordinate for each location.  You won't have to use this other than
# indirectly through the flight cost function.
def setup_location_coords(options):
    location_coords = [(0, 0)]  # For the depot
    for x in range(1, options.locations + 1):
        location_coords.append((random.randint(1, 35), random.randint(1, 35)))

    print("Location positions", location_coords)
    return location_coords


# This function generates a random set of goals.
# After you run this, need[personid][contentid] is true if and only if
# the goal is for the person to have a crate with the specified content.
# You will use this to create goal statements in PDDL.
def setup_person_needs(options, crates_with_contents):
    need = [[False for i in range(len(content_types))] for j in range(options.persons)]
    goals_per_contents = [0 for i in range(len(content_types))]

    for goalnum in range(options.goals):

        generated = False
        while not generated:
            rand_person = random.randint(0, options.persons - 1)
            rand_content = random.randint(0, len(content_types) - 1)
            # If we have enough crates with that content
            # and the person doesn't already need that content
            if (goals_per_contents[rand_content] < len(crates_with_contents[rand_content])
                    and not need[rand_person][rand_content]):
                need[rand_person][rand_content] = True
                goals_per_contents[rand_content] += 1
                generated = True
    return need


########################################################################################
# Main program
########################################################################################
def main():
    # Take in all arguments and print them to standard output
    parser = OptionParser(usage='python generator.py [-help] options...')
    parser.add_option('-d', '--drones', metavar='NUM', dest='drones', action='store', type=int, help='the number of drones')
    parser.add_option('-r', '--containers', metavar='NUM', type=int, dest='containers')
    parser.add_option('-l', '--locations', metavar='NUM', type=int, dest='locations',
                      help='the number of locations apart from the depot ')
    parser.add_option('-p', '--persons', metavar='NUM', type=int, dest='persons', help='the number of persons')
    parser.add_option('-c', '--crates', metavar='NUM', type=int, dest='crates', help='the number of crates available')
    parser.add_option('-g', '--goals', metavar='NUM', type=int, dest='goals',
                      help='the number of crates assigned in the goal')
    # Nueva opción para especificar el path de salida
    parser.add_option('-o', '--output', metavar='PATH', dest='output',
                      default='problemasGenerados', help='El directorio en el que se generará el problema')
    
    (options, args) = parser.parse_args()
    
    # Validaciones de opciones obligatorias
    if options.drones is None:
        print("You must specify --drones (use --help for help)")
        sys.exit(1)
    if options.containers is None:
        print("You must specify --containers (use --help for help)")
        sys.exit(1)
    if options.locations is None:
        print("You must specify --locations (use --help for help)")
        sys.exit(1)
    if options.persons is None:
        print("You must specify --persons (use --help for help)")
        sys.exit(1)
    if options.crates is None:
        print("You must specify --crates (use --help for help)")
        sys.exit(1)
    if options.goals is None:
        print("You must specify --goals (use --help for help)")
        sys.exit(1)
    
    if options.goals > options.crates:
        print("Cannot have more goals than crates")
        sys.exit(1)
    
    if len(content_types) > options.crates:
        print("Cannot have more content types than crates:", content_types)
        sys.exit(1)
    
    if options.goals > len(content_types) * options.persons:
        print("For", options.persons, "persons, you can have at most", len(content_types) * options.persons, "goals")
        sys.exit(1)
    
    print("Drones\t\t", options.drones)
    print("Containers\t", options.containers)
    print("Locations\t", options.locations)
    print("Persons\t\t", options.persons)
    print("Crates\t\t", options.crates)
    print("Goals\t\t", options.goals)
    print("Output path:\t", options.output)
    
    # Asegurarse de que el directorio de salida exista
    if not os.path.exists(options.output):
        os.makedirs(options.output)
        print("Directorio de salida creado:", options.output)
    
    # Setup all lists of objects
    drone = []
    person = []
    crate = []
    containers = []
    location = []
    
    location.append("deposito")
    for x in range(options.locations):
        location.append("loc" + str(x + 1))
    for x in range(options.drones):
        drone.append("dron" + str(x + 1))
    for x in range(options.persons):
        person.append("pers" + str(x + 1))
    for x in range(options.crates):
        crate.append("caja" + str(x + 1))
    for x in range(options.containers):
        containers.append("k" + str(x + 1))
    
    # Determinar el set de cajas para cada contenido y otras configuraciones
    crates_with_contents = setup_content_types(options)
    location_coords = setup_location_coords(options)
    need = setup_person_needs(options, crates_with_contents)
    
    # Define a problem name
    problem_name = "drone_problem_d" + str(options.drones) + \
                   "_l" + str(options.locations) + "_p" + str(options.persons) + "_c" + str(options.crates) + \
                   "_g" + str(options.goals) + "_ct" + str(len(content_types))
    
    # Construir la ruta completa del archivo de salida
    output_file = os.path.join(options.output, problem_name + ".pddl")
    
    # Open output file
    with open(output_file, 'w') as f:
        # Write the initial part of the problem
        f.write("(define (problem " + problem_name + ")\n")
        f.write("(:domain dominio-drones-2)\n")
        f.write("(:objects\n")
    
        ######################################################################
        # Write objects
        f.write("\t")
        for x in drone:
            f.write(x + " ")
        f.write("- dron\n")
        f.write("\t")
        for x in location:
            f.write(x + " ")
        f.write("- localizacion\n")
        f.write("\t")
        for x in crate:
            f.write(x + " ")
        f.write("- caja\n")
        f.write("\t")
        for x in content_types:
            f.write(x + " ")
        f.write("- contenido\n")
        f.write("\t")
        for x in person:
            f.write(x + " ")
        f.write("- persona\n")
        f.write("\t")
        for x in containers:
            f.write(x + " ")
        f.write("- contenedor\n")  

        f.write("n0 n1 n2 n3 n4 - num\n")  
    
        f.write(")\n")
    
        ######################################################################
        # Generate an initial state
        f.write("(:init\n")
    
        for d in drone:
            f.write("\t(dron-en " + d + " deposito)\n")
            f.write("\t(dron-libre " + d + ")\n")
            f.write("\t(dron-sin-caja " + d + ")\n")
            f.write("\n")
        f.write("\t(en-deposito deposito) \n")

        for c in containers:
            f.write("\t(contenedor-libre " + c + ")\n")
        f.write(f"\n")
        for c in crates_with_contents[0]:
            f.write("\t(caja-en "+c+" deposito) ")
            f.write("(caja-libre "+c+")")
            f.write("(contiene "+c+" comida)\n")
        f.write(f"\n")
        for c in crates_with_contents[1]:
            f.write("\t(caja-en "+c+" deposito)")
            f.write("(caja-libre "+c+")")
            f.write("(contiene "+c+" medicina)\n")
        f.write(f"\n")
        for i, p in enumerate(need):
            f.write(f"\t(persona-en pers{i+1} loc{i+1})")
            if (p[0]):
                f.write(f"(necesita pers{i+1} comida)\n")
            if (p[1]):
                f.write(f"(necesita pers{i+1} medicina)\n")
            if (not (p[0] or p[1])):
                f.write(f"\n")
        
        f.write(f"\n")
        
        for i in range(len(location_coords)):
            for j in range(len(location_coords)):
                if i != j:
                    loc_i = "deposito" if i == 0 else "loc" + str(i)
                    loc_j = "deposito" if j == 0 else "loc" + str(j)
                    cost = flight_cost(location_coords, i, j)
                    f.write(f"\t(= (fly-cost {loc_i} {loc_j}) {cost})\n")
        f.write(f"\n")
        for c in containers:
            f.write("\t(cajas-en-contenedor " + c + " n0)\n")
        f.write(f"\n")
        f.write("\t(cero n0) \n\t(siguiente n0 n1) \n\t(siguiente n1 n2) \n\t(siguiente n2 n3) \n\t(siguiente n3 n4)")
        f.write("\t(= (total-cost) 0)\n")
    
        f.write(")\n")
    
        ######################################################################
        # Write Goals
        f.write("(:goal (and\n")
    
        # All Drones should end up at the depot
        for d in drone:
            f.write("\t(dron-en " + d + " deposito)\n")
    
        for x in range(options.persons):
            for y in range(len(content_types)):
                if need[x][y]:
                    person_name = person[x]
                    content_name = content_types[y]
                    f.write("\t(tiene "+person_name+" "+content_name+")\n")
    
        f.write("\t))\n")
        f.write("(:metric minimize (total-cost))")
        f.write(")\n")

if __name__ == '__main__':
    main()
