(define (problem drone_problem_d2_r2_l4_p4_c5_g5_ct2)
(:domain drone-domain)
(:objects
dron1 dron2 - dron
deposito loc1 loc2 loc3 loc4 - localizacion
- caja
comida medicina - contenido
pers1 pers2 pers3 pers4 - persona
caja1 caja2 - brazo
)
(:init
	dron-en dron1 - deposito
	brazo-libre dron1 - caja1
	brazo-libre dron1 - caja2

	dron-en dron2 - deposito
	brazo-libre dron2 - caja1
	brazo-libre dron2 - caja2

)
(:goal (and
	dron-en dron1 - deposito
	dron-en dron2 - deposito
	))
)
