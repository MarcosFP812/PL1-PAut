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
    """Context manager to limit execution time."""
    def signal_handler(signum, frame):
        raise TimeoutException("Timed out!")
    signal.signal(signal.SIGALRM, signal_handler)
    signal.alarm(seconds)
    try:
        yield
    finally:
        signal.alarm(0)

def find_newest_problem_file(directory="parte1/generadores"):
    """Find the most recently created problem file in the specified directory."""
    problem_files = glob.glob(f"drone_problem_*.pddl")
    if not problem_files:
        return None
    
    # Sort by creation time, newest first
    problem_files.sort(key=os.path.getctime, reverse=True)
    return problem_files[0]


def generate_problem(drones, carriers, locations, persons, crates, goals):
    """Generate a PDDL problem file with the given parameters."""
    
    # Get list of files before generation
    before_files = set(glob.glob("parte1/problemasGenerados/drone_problem_*.pddl"))
    
    
    cmd = [
        "python3", "parte1/generadores/generadorAleatorio.py",
        "--drones", str(drones),
        "--carriers", str(carriers),
        "--locations", str(locations),
        "--persons", str(persons),
        "--crates", str(crates),
        "--goals", str(goals)
    ]
    
    print(f"Running command: {' '.join(cmd)}")
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        # Print output for debugging
        print(f"Command output (stdout): {result.stdout}")
        print(f"Command errors (stderr): {result.stderr}")
        
        
        # Get list of files after generation
        after_files = set(glob.glob("parte1/problemasGenerados/drone_problem_*.pddl"))
        
        # Find new files
        new_files = after_files - before_files
        
        if new_files:
            problem_path = list(new_files)[0]
            print(f"Found newly created problem file: {problem_path}")
            return problem_path
        else:
            return
            
    except Exception as e:
        print(f"Exception generating problem: {e}")
        return 

def run_planner(domain_file, problem_file, planner_path, time_limit_seconds=60):
    """Run the planner with the given domain and problem files."""
    print("Ejecutando comando... ")
    # Make sure files exist
    if not os.path.exists(domain_file):
        print(f"Domain file does not exist: {domain_file}")
        return None, 0
    if not os.path.exists(problem_file):
        print(f"Problem file does not exist: {problem_file}")
        return None, 0
    if not os.path.exists(planner_path):
        print(f"Planner does not exist: {planner_path}")
        return None, 0
    
    # Make sure the planner is executable
    if not os.access(planner_path, os.X_OK):
        print(f"Planner file is not executable: {planner_path}")
        os.chmod(planner_path, 0o755)  # Try to make it executable
        print("Tried to make the planner executable")
    
    # FF planner command
    if planner_path == "planificadores/lpg-td":
        print("En lpg")
        cmd = [planner_path, "-o", domain_file, "-f", problem_file, "-n", "1"]
    else: 
        cmd = [planner_path, "-o", domain_file, "-f", problem_file]
    
    print(f"Running command: {' '.join(cmd)}")
    
    start_time = time.time()
    try:
        with time_limit(time_limit_seconds):
            result = subprocess.run(cmd, capture_output=True, text=True)
            end_time = time.time()
            execution_time = end_time - start_time
            
            # Print detailed output for debugging
            print(f"Return code: {result.returncode}")
            print(f"Stdout first 300 chars: {result.stdout[:300]}")
            print(f"Stderr first 300 chars: {result.stderr[:300]}")
            
            # FF planner typically returns 0 for success and non-zero for failures
            if result.returncode != 0:
                # Check if it's a legitimate "no solution exists" message
                if "goal can be simplified to FALSE" in result.stderr or "goal can be simplified to FALSE" in result.stdout:
                    print("Planner determined that no solution exists for this problem")
                    return None, execution_time
                elif "No plan will solve it" in result.stderr or "No plan will solve it" in result.stdout:
                    print("Planner determined that no solution exists for this problem")
                    return None, execution_time
                else:
                    print(f"Planner failed with error code {result.returncode}")
                    return None, execution_time
            
            # Try to extract plan length from output
            plan_length = None
            output = result.stdout
            
            # FF planner typically reports plan length like "found legal plan as follows" followed by steps
            plan_match = re.search(r"found legal plan.+\n.+length: (\d+)", output, re.DOTALL)
            if plan_match:
                plan_length = int(plan_match.group(1))
                return plan_length, execution_time
            
            # Also look for step count in the output
            step_count = len(re.findall(r"step\s+\d+:", output))
            if step_count > 0:
                print(f"Found {step_count} steps in the plan")
                return step_count, execution_time
            
            # Look for number of actions in the plan
            if "ff: found legal plan as follows" in output or "found legal plan as follows" in output:
                lines_after_plan = output.split("found legal plan as follows")[1].strip().split("\n")
                action_count = sum(1 for line in lines_after_plan if line.strip() and not line.startswith("plan cost:") and not line.startswith("time spent:"))
                if action_count > 0:
                    print(f"Found {action_count} actions in the plan")
                    return action_count, execution_time
            
            # If no plan length found but return code was 0, assume success but report unknown length
            print("No plan length found in output despite successful return code")
            return 0, execution_time  # Return 0 as length but mark as success
    except TimeoutException:
        print(f"Planner timed out after {time_limit_seconds} seconds")
        return None, time_limit_seconds
    except Exception as e:
        print(f"Exception running planner: {e}")
        return None, time.time() - start_time

def delete_problem_file(problem_file):
    """Delete the generated problem file."""
    if problem_file and os.path.exists(problem_file):
        try:
            os.remove(problem_file)
            print(f"Deleted {problem_file}")
        except Exception as e:
            print(f"Error deleting problem file {problem_file}: {e}")
    for file in glob.glob("*drone_problem*"):
        os.remove(file)
        print(f"Eliminado: {file}")


def plot_results(sizes, times, solutions_found, max_size, planner_name):
    """Create a plot of problem size vs. execution time, customized per planner."""
    plt.figure(figsize=(10, 6))
    
    # Plot all points
    plt.scatter(sizes, times, c=['green' if solved else 'red' for solved in solutions_found], 
                marker='o', s=100, label='Problem instances')
    
    # Connect the points with a line
    plt.plot(sizes, times, linestyle='-', color='blue', alpha=0.5)
    
    plt.axhline(y=60, color='r', linestyle='--', label='Time Limit (60s)')
    
    title = f'PDDL Planner Performance ({planner_name})'
    if max_size is not None:
        title += f' (Max Solvable Size: {max_size})'
    plt.title(title)
    
    plt.xlabel('Problem Size (number of locations/persons/crates/goals)')
    plt.ylabel('Execution Time (seconds)')
    plt.grid(True)
    
    # Create a custom legend
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='green', markersize=10, label='Solution Found'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='red', markersize=10, label='No Solution'),
        Line2D([0], [0], color='r', linestyle='--', label='Time Limit (60s)')
    ]
    plt.legend(handles=legend_elements)
    
    # File names based on planner name
    safe_planner_name = planner_name.replace(" ", "_").lower()  # Avoid spaces in filenames
    plot_filename = f'planner_performance_{safe_planner_name}.png'
    csv_filename = f'planner_results_{safe_planner_name}.csv'

    # Save the plot
    plt.savefig(plot_filename)
    print(f"Plot saved as '{plot_filename}'")

    # Save results as CSV
    with open(csv_filename, 'w') as f:
        f.write('Problem Size,Execution Time (s),Solution Found\n')
        for size, time_val, solved in zip(sizes, times, solutions_found):
            f.write(f'{size},{time_val},{1 if solved else 0}\n')
    print(f"Results also saved as '{csv_filename}'")

def main():
    parser = argparse.ArgumentParser(description='Run PDDL tests with increasing complexity')
    parser.add_argument('--planner', default='parte1/planificadores/ff', help='Path to the planner executable')
    parser.add_argument('--domain', default='parte1/pddl/dominio-drones.pddl', help='Path to the domain file')
    parser.add_argument('--start-size', type=int, default=2, help='Starting problem size')
    parser.add_argument('--max-size', type=int, default=100, help='Maximum problem size to try')
    parser.add_argument('--timeout', type=int, default=60, help='Timeout in seconds')
    parser.add_argument('--continue-on-fail', action='store_true', help='Continue testing even after failures')
    
    args = parser.parse_args()
    
    # SACO EL NOMBRE DEL PLANIFICADOR
    planner_name = os.path.basename(args.planner)

    # Print current working directory and check file existence for debugging
    print(f"Current working directory: {os.getcwd()}")
    print(f"Planner exists: {os.path.exists(args.planner)}")
    print(f"Domain file exists: {os.path.exists(args.domain)}")
    print(f"parte1/problemasGenerados directory exists: {os.path.exists('parte1/problemasGenerados')}")
    
    sizes = []
    times = []
    solutions_found = []
    max_solvable_size = None
    
    print(f"Testing problems from size {args.start_size} to {args.max_size} with timeout {args.timeout}s")
    print("-" * 80)
    
    consecutive_failures = 0
    
    for size in range(args.start_size, args.max_size + 1):
        print(f"Testing problem of size {size}...")
        
        problem_file = generate_problem(
            drones=1,
            carriers=1,
            locations=size,
            persons=size,
            crates=size,
            goals=size,
        )
        
        if not problem_file:
            print(f"Failed to generate problem of size {size}")
            if not args.continue_on_fail:
                consecutive_failures += 1
                if consecutive_failures >= 2:
                    print("Two consecutive failures in problem generation, stopping tests")
                    break
            continue
        
        print(f"Generated {problem_file}, running planner...")
        plan_length, execution_time = run_planner(
            args.domain,
            problem_file,
            args.planner,
            args.timeout
        )
        
        sizes.append(size)
        times.append(execution_time)
        
        if plan_length is not None:
            print(f"Size {size}: Found plan of length {plan_length} in {execution_time:.2f} seconds")
            solutions_found.append(True)
            max_solvable_size = size
            consecutive_failures = 0
        else:
            print(f"Size {size}: No solution found within {args.timeout} seconds")
            solutions_found.append(False)
            if not args.continue_on_fail:
                consecutive_failures += 1
                if consecutive_failures >= 2:
                    print("Two consecutive failures in finding solutions, stopping tests")
            break
            
        delete_problem_file(problem_file)
        print("-" * 80)
    
    if sizes and times:
        plot_results(sizes, times, solutions_found, max_solvable_size, planner_name)
        if max_solvable_size:
            print(f"Maximum problem size solved within {args.timeout} seconds: {max_solvable_size}")
        else:
            print(f"No problems were successfully solved within {args.timeout} seconds")
    else:
        print("No data collected, cannot create graph")

if __name__ == "__main__":
    main()