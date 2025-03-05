(define (problem drone_problem_d1_r0_l5_p5_c5_g5_ct2)
(:domain dominio-drones)
(:objects
	dron1 - dron
	deposito loc1 loc2 loc3 loc4 loc5 - localizacion
	caja1 caja2 caja3 caja4 caja5 - caja
	comida medicina - contenido
	pers1 pers2 pers3 pers4 pers5 - persona
	- brazo
)
(:init
	(dron-en dron1 deposito)
	(caja-en caja1 loc3) (contiene caja1 medicina)
	(caja-en caja2 loc2) (contiene caja2 comida)
	(caja-en caja3 loc1) (contiene caja3 comida)
	(caja-en caja4 loc1) (contiene caja4 medicina)
	(caja-en caja5 loc5) (contiene caja5 medicina)
	(persona-en pers1 loc5)
	(necesita pers1 comida)
	(necesita pers1 medicina)
	(persona-en pers2 loc2)
	(necesita pers2 comida)
	(persona-en pers3 loc3)
	(necesita pers3 comida)
	(necesita pers3 medicina)
	(persona-en pers4 loc5)
	(necesita pers4 comida)
	(necesita pers4 medicina)
	(persona-en pers5 loc5)
)
(:goal (and
	(dron-en dron1 deposito)
	(tiene pers1 comida)
	(tiene pers1 medicina)
	(tiene pers2 comida)
	(tiene pers3 comida)
	(tiene pers3 medicina)
	(tiene pers4 comida)
	(tiene pers4 medicina)
))
