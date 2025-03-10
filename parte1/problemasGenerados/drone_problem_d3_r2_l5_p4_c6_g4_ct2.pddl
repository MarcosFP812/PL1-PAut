(define (problem drone_problem_d3_r2_l5_p4_c6_g4_ct2)
(:domain dominio-drones)
(:objects
	dron1 dron2 dron3 - dron
	deposito loc1 loc2 loc3 loc4 loc5 - localizacion
	caja1 caja2 caja3 caja4 caja5 caja6 - caja
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
	(dron-en dron3 deposito)
	(brazo-libre dron3 brazo1)
	(brazo-libre dron3 brazo2)
	(caja-en caja1 loc5) (contiene caja1 medicina)
	(caja-en caja2 loc4) (contiene caja2 medicina)
	(caja-en caja3 loc2) (contiene caja3 comida)
	(caja-en caja4 loc2) (contiene caja4 comida)
	(caja-en caja5 loc3) (contiene caja5 medicina)
	(caja-en caja6 loc2) (contiene caja6 medicina)
	(persona-en pers1 loc3)
	(necesita pers1 comida)
	(persona-en pers2 loc1)
	(persona-en pers3 loc4)
	(necesita pers3 comida)
	(persona-en pers4 loc1)
)
(:goal (and
	(dron-en dron1 deposito)
	(dron-en dron2 deposito)
	(dron-en dron3 deposito)
	(tiene pers1 comida)
	(tiene pers3 comida)
	))
)
