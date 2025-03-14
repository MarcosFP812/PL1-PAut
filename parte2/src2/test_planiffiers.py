#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import time
import os
import argparse
import re
import signal
import matplotlib.pyplot as plt
from contextlib import contextmanager
import glob
import random

class TimeoutException(Exception):
    pass

@contextmanager
def time_limit(seconds):
    """
    Context manager para limitar la ejecución a un tiempo (segundos).
    Lanza una excepción TimeoutException si excede el límite.
    """
    def signal_handler(signum, frame):
        raise TimeoutException("Timed out!")
    signal.signal(signal.SIGALRM, signal_handler)
    signal.alarm(seconds)
    try:
        yield
    finally:
        signal.alarm(0)

def generate_problem(drones, carriers, locations, persons, crates, goals):
    """
    Llama al script generate_problem.py para crear un problema PDDL
    con los parámetros dados.
    Devuelve la ruta del nuevo archivo problema .pddl generado,
    o None si falla.
    """
    before_files = set(glob.glob("problemasGenerados/drone_problem_*.pddl"))
    
    cmd = [
        "python3", "generate_problem.py",
        "--drones", str(drones),
        "--containers", str(carriers),
        "--locations", str(locations),
        "--persons", str(persons),
        "--crates", str(crates),
        "--goals", str(goals),
        "--output", "problemasGenerados"
    ]
    
    print(f"Ejecutando: {' '.join(cmd)}")
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        # Debug
        print("Salida de generate_problem.py:\n", result.stdout)
        print("Errores de generate_problem.py:\n", result.stderr)
        
        if result.returncode != 0:
            print("ERROR al generar problema")
            return None
        
        after_files = set(glob.glob("problemasGenerados/drone_problem_*.pddl"))
        new_files = after_files - before_files
        if new_files:
            problem_path = list(new_files)[0]
            print(f"Fichero problema generado: {problem_path}")
            return problem_path
        else:
            print("No se encontró ningún fichero nuevo tras generación.")
            return None
    except Exception as e:
        print(f"Excepción generando problema: {e}")
        return None

def run_planner(domain_file, problem_file, planner_alias, time_limit_seconds=60):
    """
    Ejecuta el planificador con el dominio y problema dados.
    Devuelve (plan_length, execution_time, plan_cost) o (None, time, None) si falla/timeout.
    """
    if not os.path.exists(domain_file):
        print(f"Archivo de dominio no existe: {domain_file}")
        return None, 0, None
    if not os.path.exists(problem_file):
        print(f"Archivo de problema no existe: {problem_file}")
        return None, 0, None
    
    # Construimos el comando según sea metricff o fast-downward
    if planner_alias == "planificadores/metricff":
        cmd = [planner_alias, "-o", domain_file, "-f", problem_file]
    else:
        # Asumimos que se usa fast-downward con alias (ej: lama-first, seq-opt-lmcut, etc.)
        if planner_alias in ["seq-sat-fdss-2", "seq-opt-fdss-2"]:
            cmd = ["planificadores/fast-downward.sif", 
                   "--alias", planner_alias, 
                   "--overall-time", "55", 
                   domain_file, problem_file]
        else:
            # Ej: lama-first, seq-opt-lmcut, etc.
            cmd = ["planificadores/fast-downward.sif", 
                   "--alias", planner_alias, 
                   domain_file, problem_file]
    
    print(f"Ejecutando planificador: {' '.join(cmd)}")
    start_time = time.time()
    
    try:
        with time_limit(time_limit_seconds):
            result = subprocess.run(cmd, capture_output=True, text=True)
        end_time = time.time()
        execution_time = end_time - start_time
        
        print(f"Return code: {result.returncode}")
        # Mostramos parte de la salida para debug
        print(">> STDOUT:\n", result.stdout[:400])
        print(">> STDERR:\n", result.stderr[:400])
        
        combined_output = result.stdout + "\n" + result.stderr
        
        # Buscamos "plan cost: X"
        plan_cost = None
        cost_match = re.search(r"[Pp][Ll][Aa][Nn]\s*[Cc][Oo][Ss][Tt]:\s*(\d+\.?\d*)", combined_output)
        if cost_match:
            plan_cost = float(cost_match.group(1))
            print(f"Encontrado plan cost: {plan_cost}")
        
        # Si returncode != 0, verificar si es "no hay solución"
        if result.returncode != 0:
            no_sol = any(kw in combined_output for kw in [
                "goal can be simplified to FALSE",
                "No plan will solve it",
                "unsolvable"
            ])
            if no_sol:
                print("No hay solución para este problema.")
                return None, execution_time, None
            else:
                print("Fallo en el planificador.")
                return None, execution_time, None
        
        # Buscar la longitud del plan
        output = result.stdout
        plan_length = None
        
        # Si es FF-like: "found legal plan as follows\n...\nlength: 10"
        plan_match = re.search(r"found legal plan.+\n.+length: (\d+)", output, re.DOTALL)
        if plan_match:
            plan_length = int(plan_match.group(1))
            print(f"Plan length: {plan_length}")
            return plan_length, execution_time, plan_cost
        
        # Para planes que muestran steps (ej: "step 0: ... step 1: ...")
        step_count = len(re.findall(r"step\s+\d+:", output))
        if step_count > 0:
            print(f"Plan con {step_count} pasos.")
            return step_count, execution_time, plan_cost
        
        # En caso de no encontrar la longitud, devolvemos 0 con un plan cost
        print("Éxito, pero no encontré la longitud del plan, se asume 0.")
        return 0, execution_time, plan_cost
    
    except TimeoutException:
        print(f"El planificador superó el tiempo límite de {time_limit_seconds}s.")
        return None, time_limit_seconds, None
    except Exception as e:
        print(f"Excepción al ejecutar el planificador: {e}")
        return None, 0, None

def delete_problem_file(problem_file):
    """
    Elimina el archivo de problema dado y cualquier residual con 'drone_problem' en el nombre.
    """
    if problem_file and os.path.exists(problem_file):
        try:
            os.remove(problem_file)
            print(f"Borrado fichero: {problem_file}")
        except Exception as e:
            print(f"Error al borrar {problem_file}: {e}")
    # Borrar cualquier residual
    for file in glob.glob("*drone_problem*"):
        try:
            os.remove(file)
            print(f"Borrado residual: {file}")
        except:
            pass

def limpiar_carpeta_problemas():
    """
    Elimina todos los archivos dentro de la carpeta problemasGenerados.
    """
    carpeta = "problemasGenerados"
    if os.path.exists(carpeta):
        for archivo in os.listdir(carpeta):
            ruta_completa = os.path.join(carpeta, archivo)
            if os.path.isfile(ruta_completa):
                try:
                    os.remove(ruta_completa)
                    print(f"Eliminado: {ruta_completa}")
                except Exception as e:
                    print(f"Error eliminando {ruta_completa}: {e}")

def plot_results(sizes, times, costs, solutions_found, max_size, planner=""):
    """
    Genera 2 gráficos:
      1. Tamaño vs. Tiempo de ejecución
      2. Tamaño vs. Coste del plan
    Y guarda un CSV con resultados.
    """
    if planner.startswith("planificadores/"):
        planner = planner.replace("planificadores/", "")
    
    os.makedirs('results', exist_ok=True)

    # -- PLOT 1: Tiempo vs. Tamaño
    plt.figure(figsize=(10, 6))
    plt.scatter(sizes, times, c=['green' if s else 'red' for s in solutions_found],
                marker='o', s=100, label='Problem instances')
    # Unimos los puntos con línea
    plt.plot(sizes, times, linestyle='-', color='blue', alpha=0.5)
    # Línea horizontal de límite de tiempo (opcional)
    plt.axhline(y=60, color='r', linestyle='--', label='Time Limit (60s)')

    title = "PDDL Planner Performance (Execution Time)"
    if max_size:
        title += f" (Max Solvable Size: {max_size})"
    plt.title(title)
    plt.xlabel("Problem Size (locations/persons/crates/goals)")
    plt.ylabel("Execution Time (seconds)")
    plt.grid(True)

    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='green',
               markersize=10, label='Solution Found'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='red',
               markersize=10, label='No Solution'),
        Line2D([0], [0], color='r', linestyle='--', label='Time Limit')
    ]
    plt.legend(handles=legend_elements)

    time_plot_path = f"results/planner_performance_time_{planner}.png"
    plt.savefig(time_plot_path)
    print(f"Guardado gráfico de tiempo: {time_plot_path}")

    # -- PLOT 2: Coste vs. Tamaño (solo si hay costes)
    if any(c is not None for c in costs):
        plt.figure(figsize=(10, 6))
        valid_data = [(sz, c) for sz, c, sol in zip(sizes, costs, solutions_found)
                      if c is not None and sol]
        if valid_data:
            valid_sizes, valid_costs = zip(*valid_data)
            plt.scatter(valid_sizes, valid_costs, color='green', marker='o', s=100)
            plt.plot(valid_sizes, valid_costs, linestyle='-', color='blue', alpha=0.5)

            cost_title = "PDDL Planner Performance (Plan Cost)"
            if max_size:
                cost_title += f" (Max Solvable Size: {max_size})"
            plt.title(cost_title)
            plt.xlabel("Problem Size (locations/persons/crates/goals)")
            plt.ylabel("Plan Cost")
            plt.grid(True)

            cost_plot_path = f"results/planner_performance_cost_{planner}.png"
            plt.savefig(cost_plot_path)
            print(f"Guardado gráfico de coste: {cost_plot_path}")

    # -- CSV con todos los datos
    csv_path = f"results/planner_results_{planner}.csv"
    with open(csv_path, "w") as f:
        f.write("ProblemSize,ExecutionTime,PlanCost,SolutionFound\n")
        for sz, t, c, sol in zip(sizes, times, costs, solutions_found):
            cost_str = f"{c}" if c is not None else "N/A"
            f.write(f"{sz},{t:.4f},{cost_str},{int(sol)}\n")
    print(f"Guardado CSV de resultados: {csv_path}")

def main():
    parser = argparse.ArgumentParser(description='Ejecución de planificadores PDDL con problemas crecientes.')
    parser.add_argument('--planner', default='lama-first',
                        help='Alias del planificador (ej: lama-first, seq-opt-lmcut, metricff, etc.)')
    parser.add_argument('--domain', default='dominio-drones-parte-2.pddl',
                        help='Archivo de dominio PDDL.')
    parser.add_argument('--start-size', type=int, default=2,
                        help='Tamaño inicial de problema (lugares, personas, cajas, metas).')
    parser.add_argument('--max-size', type=int, default=30,
                        help='Tamaño máximo de problema a intentar.')
    parser.add_argument('--timeout', type=int, default=60,
                        help='Tiempo límite (s) para cada planificación.')
    parser.add_argument('--continue-on-fail', action='store_true',
                        help='Si se activa, continúa generando problemas aun si hay fallas/timeout consecutivos.')
    parser.add_argument('--step-size', type=int, default=5,
                        help='Incremento del tamaño en cada iteración.')
    args = parser.parse_args()

    print(f"Dominio: {args.domain}")
    print(f"Planificador: {args.planner}")
    print(f"Tamaño inicial: {args.start_size}, Tamaño máximo: {args.max_size}, step: {args.step_size}")
    print(f"Timeout: {args.timeout} s")

    sizes = []
    times_list = []
    costs = []
    solutions_found = []
    max_solvable_size = None

    consecutive_failures = 0
    for size in range(args.start_size, args.max_size + 1, args.step_size):
        print("="*70)
        print(f"Generando problema con tamaño {size} ...")

        problem_file = generate_problem(
            drones=1,
            carriers=1,
            locations=size,
            persons=size,
            crates=size,
            goals=size
        )
        if not problem_file:
            print("Fallo generando problema.")
            if not args.continue_on_fail:
                consecutive_failures += 1
                if consecutive_failures >= 2:
                    print("Se detiene por fallos consecutivos en generación.")
                    break
            continue
        
        # Ejecutar planificador
        print(f"Ejecutando planificador en {problem_file}")
        plan_length, exec_time, plan_cost = run_planner(
            args.domain, problem_file, args.planner, args.timeout
        )

        # Registrar datos
        sizes.append(size)
        times_list.append(exec_time)
        costs.append(plan_cost)

        if plan_length is not None:
            solutions_found.append(True)
            max_solvable_size = size
            consecutive_failures = 0
            print(f"Solución encontrada: longitud {plan_length}, coste {plan_cost}, tiempo {exec_time:.2f}s")
        else:
            solutions_found.append(False)
            print(f"No se encontró solución en {exec_time:.2f}s (o falló).")
            if not args.continue_on_fail:
                consecutive_failures += 1
                if consecutive_failures >= 2:
                    print("Se detiene por fallos consecutivos en planificación.")
                    break

        # Borrar archivo de problema
        delete_problem_file(problem_file)
        # Limpieza residual
        limpiar_carpeta_problemas()

    # Crear gráficos si tenemos al menos un problema
    if sizes:
        plot_results(sizes, times_list, costs, solutions_found, max_solvable_size, args.planner)
        if max_solvable_size:
            print(f"\nMayor tamaño resuelto: {max_solvable_size}")
        else:
            print("\nNo se resolvieron problemas con éxito.")
    else:
        print("\nNo se han recopilado datos, no se generan gráficos.")

if __name__ == "__main__":
    try:
        main()
    finally:
        # Limpieza final
        print("\nLimpieza final de problemasGenerados ...")
        limpiar_carpeta_problemas()