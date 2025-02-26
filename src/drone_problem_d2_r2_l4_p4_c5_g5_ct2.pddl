(define (problem drone_problem_d2_r2_l4_p4_c5_g5_ct2)
(:domain dominio-drones)
(:objects
	dron1 dron2 - dron
	deposito loc1 loc2 loc3 loc4 - localizacion
	caja1 caja2 caja3 caja4 caja5 - caja
	comida medicina - contenido
	pers1 pers2 pers3 pers4 - persona
	brazo1 brazo2 - brazo
)
(:init
	(dron-en dron1 deposito)
	(brazo-libre dron1 brazo1)
	(brazo-libre dron1 brazo2)

	(dron-en dron2 deposito)
	(brazo-libre dron2 brazo1)
	(brazo-libre dron2 brazo2)

	(caja-en caja1 deposito)(contiene caja1 comida)
	(caja-en caja2 deposito)(contiene caja2 comida)
	(caja-en caja3 deposito)(contiene caja3 comida)
	(caja-en caja4 deposito)(contiene caja4 medicina)
	(caja-en caja5 deposito)(contiene caja5 medicina)
	(persona-en pers1 loc1)(necesita pers1 comida)
	(persona-en pers2 loc2)	(persona-en pers3 loc3)(necesita pers3 comida)
(necesita pers3 medicina)
	(persona-en pers4 loc4)(necesita pers4 comida)
(necesita pers4 medicina)
)
(:goal (and
	(dron-en dron1 deposito)
	(dron-en dron2 deposito)
	(tiene pers1 comida)
	(tiene pers3 comida)
	(tiene pers3 medicina)
	(tiene pers4 comida)
	(tiene pers4 medicina)
	))
)
