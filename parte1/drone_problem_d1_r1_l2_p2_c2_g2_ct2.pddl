(define (problem drone_problem_d1_r1_l2_p2_c2_g2_ct2)
(:domain dominio-drones)
(:objects
	dron1 - dron
	deposito loc1 loc2 - localizacion
	caja1 caja2 - caja
	comida medicina - contenido
	pers1 pers2 - persona
	brazo1 - brazo
)
(:init
	(dron-en dron1 deposito)
	(brazo-libre dron1 brazo1)

	(caja-en caja1 deposito)(contiene caja1 comida)
	(caja-en caja2 deposito)(contiene caja2 medicina)
	(persona-en pers1 loc1)(necesita pers1 medicina)
	(persona-en pers2 loc2)(necesita pers2 comida)
)
(:goal (and
	(dron-en dron1 deposito)
	(tiene pers1 medicina)
	(tiene pers2 comida)
	))
)
