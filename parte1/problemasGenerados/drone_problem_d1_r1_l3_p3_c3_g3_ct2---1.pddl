(define (problem drone_problem_d1_r1_l3_p3_c3_g3_ct2)
(:domain dominio-drones)
(:objects
	dron1 - dron
	deposito loc1 loc2 loc3 - localizacion
	caja1 caja2 caja3 - caja
	comida medicina - contenido
	pers1 pers2 pers3 - persona
	brazo1 - brazo
)
(:init
	(dron-en dron1 deposito)
	(brazo-libre dron1 brazo1)
	(caja-en caja1 loc2) (contiene caja1 medicina)
	(caja-en caja2 loc1) (contiene caja2 medicina)
	(caja-en caja3 loc1) (contiene caja3 medicina)
	(persona-en pers1 loc3)
	(necesita pers1 comida)
	(persona-en pers2 loc3)
	(persona-en pers3 loc2)
	(necesita pers3 medicina)
)
(:goal (and
	(dron-en dron1 deposito)
	(tiene pers1 comida)
	(tiene pers3 medicina)
	))
)
