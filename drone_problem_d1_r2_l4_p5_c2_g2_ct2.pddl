(define (problem drone_problem_d1_r2_l4_p5_c2_g2_ct2)
(:domain dominio-drones)
(:objects
	dron1 - dron
	deposito loc1 loc2 loc3 loc4 - localizacion
	caja1 caja2 - caja
	comida medicina - contenido
	pers1 pers2 pers3 pers4 pers5 - persona
	brazo1 brazo2 - brazo
)
(:init
	(dron-en dron1 deposito)
	(brazo-libre dron1 brazo1)
	(brazo-libre dron1 brazo2)
	(caja-en caja1 loc3) (contiene caja1 medicina)
	(caja-en caja2 loc1) (contiene caja2 comida)
	(persona-en pers1 loc4)
	(necesita pers1 comida)
	(necesita pers1 medicina)
	(persona-en pers2 loc2)
	(necesita pers2 comida)
	(persona-en pers3 loc3)
	(necesita pers3 comida)
	(persona-en pers4 loc3)
	(necesita pers4 medicina)
	(persona-en pers5 loc3)
	(necesita pers5 comida)
)
(:goal (and
	(dron-en dron1 deposito)
	(tiene pers1 comida)
	(tiene pers1 medicina)
	(tiene pers2 comida)
	(tiene pers3 comida)
	(tiene pers4 medicina)
	(tiene pers5 comida)
))
