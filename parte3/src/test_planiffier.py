#!/usr/bin/env python3
import subprocess
import time
import os
import re
import csv
import matplotlib.pyplot as plt
import argparse

def generate_problem(drones, containers, locations, persons, crates, goals, output_dir):
    """Genera un problema PDDL usando el script original."""
    cmd = [
        "python3", "generate_problem.py",
        "--drones", str(drones),
        "--containers", str(containers),
        "--locations", str(locations),
        "--persons", str(persons),
        "--crates", str(crates),
        "--goals", str(goals),
        "--output", output_dir
    ]
    subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    # Extraer el nombre del archivo generado
    problem_name = f"drone_problem_d{drones}_l{locations}_p{persons}_c{crates}_g{goals}_ct2.pddl"
    return os.path.join(output_dir, problem_name)

def run_planner(domain_file, problem_file, timeout=60):
    """Ejecuta el planificador con un timeout específico."""
    start_time = time.time()
    cmd = ["planificadores/optic-clp", domain_file, problem_file]
    
    try:
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                              text=True, timeout=timeout)
        execution_time = time.time() - start_time
        
        # Buscar el coste teórico en la salida
        cost_match = re.search(r"Theoretical reachable cost (\d+(\.\d+)?)", result.stdout)
        if cost_match:
            cost = float(cost_match.group(1))
        else:
            cost = None
            
        return {
            "timeout": False,
            "execution_time": execution_time,
            "cost": cost,
            "output": result.stdout
        }
    except subprocess.TimeoutExpired:
        return {
            "timeout": True,
            "execution_time": timeout,
            "cost": None,
            "output": "Timeout"
        }

def experiment_fixed_drones(domain_file, output_dir, results_dir):
    """Experimento con número fijo de drones, incrementando personas, localizaciones y cajas."""
    # Parámetros fijos
    fixed_drones = 2
    containers = 3
    goals_ratio = 0.7  # Porcentaje de cajas que serán goals
    
    # Parámetros variables (iniciales)
    persons = 2
    locations = 3
    crates = 4
    
    results = []
    timeout_reached = False
    
    while not timeout_reached:
        # Calcular goals basados en el ratio
        goals = max(1, int(crates * goals_ratio))
        
        # Generar problema
        problem_file = generate_problem(
            fixed_drones, containers, locations, persons, crates, goals, output_dir
        )
        
        print(f"Ejecutando experimento con {fixed_drones} drones, {persons} personas, {locations} localizaciones, {crates} cajas")
        
        # Ejecutar planificador
        result = run_planner(domain_file, problem_file)
        
        # Guardar resultados
        result_data = {
            "drones": fixed_drones,
            "persons": persons,
            "locations": locations,
            "crates": crates,
            "goals": goals,
            "execution_time": result["execution_time"],
            "cost": result["cost"],
            "timeout": result["timeout"]
        }
        results.append(result_data)
        
        # Verificar si se alcanzó el timeout
        if result["timeout"]:
            timeout_reached = True
            print("Timeout alcanzado.")
        else:
            print(f"Tiempo de ejecución: {result['execution_time']:.2f}s, Coste: {result['cost']}")
            
        # Incrementar parámetros para la siguiente iteración
        persons += 1
        locations += 1
        crates += 2
    
    # Guardar resultados en CSV
    csv_file = os.path.join(results_dir, "fixed_drones_results.csv")
    with open(csv_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=results[0].keys())
        writer.writeheader()
        writer.writerows(results)
    
    # Generar gráficas
    plot_results(results, "fixed_drones", results_dir)
    
    return results

def experiment_fixed_problem_size(domain_file, output_dir, results_dir):
    """Experimento con tamaño fijo del problema, incrementando el número de drones."""
    # Parámetros fijos
    persons = 5
    locations = 5
    crates = 8
    goals = 5
    containers = 3
    
    # Parámetro variable (inicial)
    drones = 1
    
    results = []
    timeout_reached = False
    
    while not timeout_reached:
        # Generar problema
        problem_file = generate_problem(
            drones, containers, locations, persons, crates, goals, output_dir
        )
        
        print(f"Ejecutando experimento con {drones} drones, {persons} personas, {locations} localizaciones, {crates} cajas")
        
        # Ejecutar planificador
        result = run_planner(domain_file, problem_file)
        
        # Guardar resultados
        result_data = {
            "drones": drones,
            "persons": persons,
            "locations": locations,
            "crates": crates,
            "goals": goals,
            "execution_time": result["execution_time"],
            "cost": result["cost"],
            "timeout": result["timeout"]
        }
        results.append(result_data)
        
        # Verificar si se alcanzó el timeout
        if result["timeout"]:
            timeout_reached = True
            print("Timeout alcanzado.")
        else:
            print(f"Tiempo de ejecución: {result['execution_time']:.2f}s, Coste: {result['cost']}")
            
        # Incrementar el número de drones
        drones += 1
    
    # Guardar resultados en CSV
    csv_file = os.path.join(results_dir, "fixed_problem_size_results.csv")
    with open(csv_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=results[0].keys())
        writer.writeheader()
        writer.writerows(results)
    
    # Generar gráficas
    plot_results(results, "fixed_problem_size", results_dir)
    
    return results

def plot_results(results, experiment_name, results_dir):
    """Genera gráficas para los resultados."""
    # Extraer datos para gráficas
    x_values = []
    execution_times = []
    costs = []
    
    if experiment_name == "fixed_drones":
        for result in results:
            # Usar una medida compuesta de complejidad: persons + locations + crates
            complexity = result["persons"] + result["locations"] + result["crates"]
            x_values.append(complexity)
            execution_times.append(result["execution_time"])
            if result["cost"] is not None:
                costs.append(result["cost"])
            else:
                costs.append(0)
        x_label = "Complejidad del problema (personas + localizaciones + cajas)"
    else:  # fixed_problem_size
        for result in results:
            x_values.append(result["drones"])
            execution_times.append(result["execution_time"])
            if result["cost"] is not None:
                costs.append(result["cost"])
            else:
                costs.append(0)
        x_label = "Número de drones"
    
    # Gráfica de tiempo de ejecución
    plt.figure(figsize=(10, 6))
    plt.plot(x_values, execution_times, marker='o', linestyle='-', color='blue')
    plt.xlabel(x_label)
    plt.ylabel("Tiempo de ejecución (s)")
    plt.title(f"Tiempo de ejecución vs {x_label}")
    plt.grid(True)
    plt.savefig(os.path.join(results_dir, f"{experiment_name}_execution_time.png"))
    plt.close()
    
    # Gráfica de coste
    plt.figure(figsize=(10, 6))
    plt.plot(x_values, costs, marker='o', linestyle='-', color='red')
    plt.xlabel(x_label)
    plt.ylabel("Coste teórico")
    plt.title(f"Coste teórico vs {x_label}")
    plt.grid(True)
    plt.savefig(os.path.join(results_dir, f"{experiment_name}_cost.png"))
    plt.close()

def main():
    parser = argparse.ArgumentParser(description='Automatizar experimentos con el planificador OPTIC-CLP')
    parser.add_argument('--domain', default='pddl/dominio-drones-parte-3.pddl', help='Archivo de dominio PDDL')
    parser.add_argument('--output-dir', default='problemasGenerados', help='Directorio para problemas generados')
    parser.add_argument('--results-dir', default='resultados', help='Directorio para resultados')
    parser.add_argument('--experiment', choices=['fixed_drones', 'fixed_problem_size', 'both'], 
                        default='both', help='Tipo de experimento a ejecutar')
    
    args = parser.parse_args()
    
    # Crear directorios si no existen
    for dir_path in [args.output_dir, args.results_dir]:
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)
    
    # Ejecutar experimentos según lo solicitado
    if args.experiment in ['fixed_drones', 'both']:
        print("Iniciando experimento con número fijo de drones...")
        experiment_fixed_drones(args.domain, args.output_dir, args.results_dir)
    
    if args.experiment in ['fixed_problem_size', 'both']:
        print("Iniciando experimento con tamaño fijo del problema...")
        experiment_fixed_problem_size(args.domain, args.output_dir, args.results_dir)
    
    print("Experimentos completados. Resultados guardados en", args.results_dir)

if __name__ == "__main__":
    main()