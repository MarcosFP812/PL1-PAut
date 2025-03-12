import subprocess
import os

# Definir los planificadores y sus rutas
planificadores = {
    "ff": "parte1/planificadores/ff",
    "lpg-td": "parte1/planificadores/lpg-td",
    "sgplan40": "parte1/planificadores/sgplan40"
}

# Rutas de dominio y problema
dominio = "parte1/pddl/dominio-drones.pddl"
problema = "parte1/problemasGenerados/drone_problem_d1_r2_l30_p30_c30_g30_ct2.pddl"

# Verificar si los archivos existen
if not os.path.exists(dominio):
    print(f"❌ Error: No se encontró el dominio {dominio}")
    exit(1)

if not os.path.exists(problema):
    print(f"❌ Error: No se encontró el problema {problema}")
    exit(1)

# Ejecutar cada planificador y guardar la solución
for nombre, ruta in planificadores.items():
    if not os.path.exists(ruta):
        print(f"⚠️ Advertencia: {nombre} no encontrado en {ruta}, saltando...")
        continue

    print(f"🚀 Ejecutando {nombre}...")

    # Definir el comando según el planificador
    if nombre == "lpg-td":
        cmd = [ruta, "-o", dominio, "-f", problema, "-n", "1"]
    else:
        cmd = [ruta, "-o", dominio, "-f", problema]

    try:
        # Ejecutar el planificador
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        
        # Verificar si encontró solución
        if result.returncode == 0 and "found legal plan" in result.stdout:
            # Guardar la solución en un archivo
            sol_file = f"solucion_{nombre}.SOL"
            with open(sol_file, "w") as f:
                f.write(result.stdout)
            print(f"✅ Solución guardada en {sol_file}")
        else:
            print(f"❌ {nombre} no encontró solución o falló.")

    except subprocess.TimeoutExpired:
        print(f"⏳ {nombre} alcanzó el límite de tiempo (60s) y fue detenido.")
    except Exception as e:
        print(f"⚠️ Error ejecutando {nombre}: {e}")

print("🎯 Finalizado.")