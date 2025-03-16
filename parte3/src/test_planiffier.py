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
        "python3", "src/generate_problem.py",
        "--drones", str(drones),
        "--containers", str(containers),
        "--locations", str(locations),
        "--persons", str(persons),
        "--crates", str(crates),
        "--goals", str(goals),
        "--output", output_dir
    ]
    try:
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        print(f"Generación de problema - Salida: {result.stdout.strip()}")
        if result.stderr:
            print(f"Generación de problema - Errores: {result.stderr.strip()}")
    except Exception as e:
        print(f"Error al generar problema: {str(e)}")
        return None
    
    # Extraer el nombre del archivo generado
    problem_name = f"drone_problem_d{drones}_l{locations}_p{persons}_c{crates}_g{goals}_ct2.pddl"
    return os.path.join(output_dir, problem_name)

def run_planner(domain_file, problem_file, timeout=60):
    """Ejecuta el planificador con un timeout específico y muestra información detallada."""
    start_time = time.time()
    cmd = ["planificadores/optic-clp", "-N", domain_file, problem_file]
    
    print(f"\nEjecutando comando: {' '.join(cmd)}")
    
    try:
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                              text=True, timeout=timeout)
        execution_time = time.time() - start_time
        
        # Mostrar salida completa del planificador
        print(f"Planificador - Salida:")
        print("=" * 40)
        print(result.stdout[:1000] + ("..." if len(result.stdout) > 1000 else ""))
        print("=" * 40)
        
        if result.stderr:
            print(f"Planificador - Errores:")
            print("=" * 40)
            print(result.stderr[:1000] + ("..." if len(result.stderr) > 1000 else ""))
            print("=" * 40)
        
        # Buscar el coste teórico en la salida
        cost_match = re.search(r"Cost: (\d+(\.\d+)?)", result.stdout)
        if cost_match:
            cost = float(cost_match.group(1))
            print(f"Coste encontrado: {cost}")
        else:
            cost = None
            print("No se encontró información de coste en la salida")
            
        # Verificar si la ejecución fue exitosa
        success = "Solution Found" in result.stdout or ";;; SOLUTION FOUND" in result.stdout
        
        return {
            "timeout": False,
            "execution_time": execution_time,
            "cost": cost,
            "output": result.stdout,
            "success": success
        }
    except subprocess.TimeoutExpired as e:
        print(f"Timeout alcanzado después de {timeout} segundos")
        return {
            "timeout": True,
            "execution_time": timeout,
            "cost": None,
            "output": "Timeout",
            "success": False
        }
    except Exception as e:
        print(f"Error al ejecutar planificador: {str(e)}")
        return {
            "timeout": False,
            "execution_time": time.time() - start_time,
            "cost": None,
            "output": f"Error: {str(e)}",
            "success": False
        }

def experiment_fixed_drones(domain_file, output_dir, results_dir):
    """Experimento con número fijo de drones, incrementando personas, localizaciones y cajas."""
    # Parámetros fijos
    fixed_drones = 2
    containers = 3
    goals_ratio = 1  # Porcentaje de cajas que serán goals
    
    # Parámetros variables (iniciales)
    persons = 2
    locations = 2
    crates = 2
    
    results = []
    timeout_reached = False
    consecutive_failures = 0
    
    while not timeout_reached and consecutive_failures < 2:
        # Calcular goals basados en el ratio
        goals = max(1, int(crates * goals_ratio))
        
        # Generar problema
        print(f"\n{'='*80}\nGenerando problema con {fixed_drones} drones, {persons} personas, {locations} localizaciones, {crates} cajas, {goals} goals\n{'='*80}")
        problem_file = generate_problem(
            fixed_drones, containers, locations, persons, crates, goals, output_dir
        )
        
        if not problem_file or not os.path.exists(problem_file):
            print(f"ERROR: No se pudo generar el archivo de problema")
            consecutive_failures += 1
            continue
            
        print(f"Problema generado: {problem_file}")
        
        # Ejecutar planificador
        print(f"Ejecutando experimento con {fixed_drones} drones, {persons} personas, {locations} localizaciones, {crates} cajas")
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
            "timeout": result["timeout"],
            "success": result["success"]
        }
        results.append(result_data)
        
        # Verificar si se alcanzó el timeout o hubo un fallo
        if result["timeout"]:
            timeout_reached = True
            print("Timeout alcanzado. Finalizando experimento.")
        elif not result["success"]:
            consecutive_failures += 1
            print(f"Fallo en la ejecución. Fallos consecutivos: {consecutive_failures}/2")
            if consecutive_failures >= 2:
                print("Se alcanzaron 2 fallos consecutivos. Finalizando experimento.")
        else:
            consecutive_failures = 0  # Reiniciar contador de fallos si hubo éxito
            print(f"Tiempo de ejecución: {result['execution_time']:.2f}s, Coste: {result['cost']}")
            
        # Incrementar parámetros para la siguiente iteración

        limpiar_carpeta_problemas()
        persons += 1
        locations += 1
        crates += 1
    
    # Guardar resultados en CSV
    if results:
        csv_file = os.path.join(results_dir, "fixed_drones_results.csv")
        with open(csv_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=results[0].keys())
            writer.writeheader()
            writer.writerows(results)
        
        # Generar gráficas
        plot_results(results, "fixed_drones", results_dir)
        
        print(f"Resultados guardados en {csv_file}")
    else:
        print("No se obtuvieron resultados para guardar")
    
    return results

def experiment_fixed_problem_size(domain_file, output_dir, results_dir):
    """Experimento con tamaño fijo del problema, incrementando el número de drones."""
    # Parámetros fijos
    persons = 10
    locations = 10
    crates = 12
    goals = 10
    containers = 3
    
    # Parámetro variable (inicial)
    drones = 1
    
    results = []
    timeout_reached = False
    consecutive_failures = 0
    
    while not timeout_reached and consecutive_failures < 2:
        # Generar problema
        print(f"\n{'='*80}\nGenerando problema con {drones} drones, {persons} personas, {locations} localizaciones, {crates} cajas, {goals} goals\n{'='*80}")
        problem_file = generate_problem(
            drones, containers, locations, persons, crates, goals, output_dir
        )
        
        if not problem_file or not os.path.exists(problem_file):
            print(f"ERROR: No se pudo generar el archivo de problema")
            consecutive_failures += 1
            continue
            
        print(f"Problema generado: {problem_file}")
        
        # Ejecutar planificador
        print(f"Ejecutando experimento con {drones} drones, {persons} personas, {locations} localizaciones, {crates} cajas")
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
            "timeout": result["timeout"],
            "success": result["success"]
        }
        results.append(result_data)
        
        # Verificar si se alcanzó el timeout o hubo un fallo
        if result["timeout"]:
            timeout_reached = True
            print("Timeout alcanzado. Finalizando experimento.")
        elif not result["success"]:
            consecutive_failures += 1
            print(f"Fallo en la ejecución. Fallos consecutivos: {consecutive_failures}/2")
            if consecutive_failures >= 2:
                print("Se alcanzaron 2 fallos consecutivos. Finalizando experimento.")
        else:
            consecutive_failures = 0  # Reiniciar contador de fallos si hubo éxito
            print(f"Tiempo de ejecución: {result['execution_time']:.2f}s, Coste: {result['cost']}")

        limpiar_carpeta_problemas()
            
        # Incrementar el número de drones
        drones += 1
        containers += 1
    
    # Guardar resultados en CSV
    if results:
        csv_file = os.path.join(results_dir, "fixed_problem_size_results.csv")
        with open(csv_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=results[0].keys())
            writer.writeheader()
            writer.writerows(results)
        
        # Generar gráficas
        plot_results(results, "fixed_problem_size", results_dir)
        
        print(f"Resultados guardados en {csv_file}")
    else:
        print("No se obtuvieron resultados para guardar")
    
    return results

def plot_results(results, experiment_name, results_dir):
    """Genera gráficas para los resultados usando el formato solicitado."""
    # Extraer datos para gráficas
    sizes = []
    times = []
    costs = []
    solutions_found = []
    
    if experiment_name == "fixed_drones":
        for result in results:
            # Usar una medida compuesta de complejidad: persons + locations + crates
            complexity = result["persons"]
            sizes.append(complexity)
            times.append(result["execution_time"])
            costs.append(result["cost"])
            solutions_found.append(result["success"])
        x_label = "Complejidad del problema (personas / localizaciones / cajas)"
        planner_name = "fixed_drones"
    else:  # fixed_problem_size
        for result in results:
            sizes.append(result["drones"])
            times.append(result["execution_time"])
            costs.append(result["cost"])
            solutions_found.append(result["success"])
        x_label = "Número de drones"
        planner_name = "fixed_problem_size"
    
    # Determinar el tamaño máximo solucionable
    max_size = None
    for i, solved in enumerate(solutions_found):
        if not solved and i > 0:
            max_size = sizes[i-1]
            break
    
    # Asegurar que existe el directorio de resultados
    os.makedirs(results_dir, exist_ok=True)
    
    # Gráfica 1: Tamaño del problema vs. Tiempo de ejecución
    plt.figure(figsize=(10, 6))
    
    # Plotear todos los puntos
    plt.scatter(sizes, times, c=['green' if solved else 'red' for solved in solutions_found], 
                marker='o', s=100, label='Instancias del problema')
    
    # Conectar los puntos con una línea
    plt.plot(sizes, times, linestyle='-', color='blue', alpha=0.5)
    
    plt.axhline(y=60, color='r', linestyle='--', label='Límite de tiempo (60s)')
    
    title = f'Rendimiento del planificador PDDL (Tiempo de ejecución) - {experiment_name}'
    if max_size is not None:
        title += f' (Tamaño máximo solucionable: {max_size})'
    plt.title(title)
    
    plt.xlabel(x_label)
    plt.ylabel('Tiempo de ejecución (segundos)')
    plt.grid(True)
    
    # Crear una leyenda personalizada
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='green', markersize=10, label='Solución encontrada'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='red', markersize=10, label='Sin solución'),
        Line2D([0], [0], color='r', linestyle='--', label='Límite de tiempo (60s)')
    ]
    plt.legend(handles=legend_elements)
    
    # Guardar la gráfica
    plt.savefig(os.path.join(results_dir, f"{experiment_name}_execution_time.png"))
    print(f"Gráfica de tiempo guardada como '{os.path.join(results_dir, f'{experiment_name}_execution_time.png')}'")
    
    # Gráfica 2: Tamaño del problema vs. Coste del plan (si hay costes disponibles)
    if any(cost is not None for cost in costs):
        plt.figure(figsize=(10, 6))
        
        # Filtrar valores None
        valid_data = [(size, cost) for size, cost, solved in zip(sizes, costs, solutions_found) if cost is not None and solved]
        
        if valid_data:
            valid_sizes, valid_costs = zip(*valid_data)
            
            # Plotear todos los puntos
            plt.scatter(valid_sizes, valid_costs, color='green', marker='o', s=100, label='Instancias del problema')
            
            # Conectar los puntos con una línea
            plt.plot(valid_sizes, valid_costs, linestyle='-', color='blue', alpha=0.5)
            
            title = f'Rendimiento del planificador PDDL (Coste del plan) - {experiment_name}'
            if max_size is not None:
                title += f' (Tamaño máximo solucionable: {max_size})'
            plt.title(title)
            
            plt.xlabel(x_label)
            plt.ylabel('Coste del plan')
            plt.grid(True)
            
            # Guardar la gráfica
            plt.savefig(os.path.join(results_dir, f"{experiment_name}_cost.png"))
            print(f"Gráfica de coste guardada como '{os.path.join(results_dir, f'{experiment_name}_cost.png')}'")

    # Guardar resultados como CSV
    csv_path = os.path.join(results_dir, f"{experiment_name}_results.csv")
    with open(csv_path, 'w', newline='') as f:
        if experiment_name == "fixed_drones":
            f.write('Complejidad,Personas,Localizaciones,Cajas,Goals,Tiempo de ejecución (s),Coste del plan,Solución encontrada\n')
            for i, result in enumerate(results):
                cost_str = str(result["cost"]) if result["cost"] is not None else "N/A"
                f.write(f'{sizes[i]},{result["persons"]},{result["locations"]},{result["crates"]},{result["goals"]},{result["execution_time"]},{cost_str},{1 if result["success"] else 0}\n')
        else:  # fixed_problem_size
            f.write('Drones,Personas,Localizaciones,Cajas,Goals,Tiempo de ejecución (s),Coste del plan,Solución encontrada\n')
            for i, result in enumerate(results):
                cost_str = str(result["cost"]) if result["cost"] is not None else "N/A"
                f.write(f'{result["drones"]},{result["persons"]},{result["locations"]},{result["crates"]},{result["goals"]},{result["execution_time"]},{cost_str},{1 if result["success"] else 0}\n')
    print(f"Resultados guardados como '{csv_path}'")


def limpiar_carpeta_problemas():
    """
    Elimina todos los archivos dentro de la carpeta problemasGenerados
    """
    carpeta = "problemasGenerados"
    try:
        if os.path.exists(carpeta):
            for archivo in os.listdir(carpeta):
                ruta_completa = os.path.join(carpeta, archivo)
                if os.path.isfile(ruta_completa):
                    os.remove(ruta_completa)
            print(f"Se han eliminado todos los archivos de {carpeta}")
        else:
            print(f"La carpeta {carpeta} no existe")
    except Exception as e:
        print(f"Error al limpiar la carpeta: {e}")

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
        print("\n" + "="*80)
        print("Iniciando experimento con número fijo de drones...")
        print("="*80)
        experiment_fixed_drones(args.domain, args.output_dir, args.results_dir)
    
    if args.experiment in ['fixed_problem_size', 'both']:
        print("\n" + "="*80)
        print("Iniciando experimento con tamaño fijo del problema...")
        print("="*80)
        experiment_fixed_problem_size(args.domain, args.output_dir, args.results_dir)
    
    print("\n" + "="*80)
    print("Experimentos completados. Resultados guardados en", args.results_dir)
    print("="*80)

if __name__ == "__main__":
    main()