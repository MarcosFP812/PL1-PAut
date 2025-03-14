(define (problem drone_problem_d1_l5_p5_c5_g5_ct2)
(:domain dominio-drones-2)
(:objects
	dron1 - dron
	deposito loc1 loc2 loc3 loc4 loc5 - localizacion
	caja1 caja2 caja3 caja4 caja5 - caja
	comida medicina - contenido
	pers1 pers2 pers3 pers4 pers5 - persona
	k1 - contenedor
n0 n1 n2 n3 n4 - num
)
(:init
	(dron-en dron1 deposito)
	(dron-libre dron1)
	(dron-sin-caja dron1)

	(en-deposito deposito) 
	(contenedor-libre k1)

	(caja-en caja1 deposito) (caja-libre caja1)(contiene caja1 comida)
	(caja-en caja2 deposito) (caja-libre caja2)(contiene caja2 comida)

	(caja-en caja3 deposito)(caja-libre caja3)(contiene caja3 medicina)
	(caja-en caja4 deposito)(caja-libre caja4)(contiene caja4 medicina)
	(caja-en caja5 deposito)(caja-libre caja5)(contiene caja5 medicina)

	(persona-en pers1 loc1)(necesita pers1 medicina)
	(persona-en pers2 loc2)(necesita pers2 comida)
	(persona-en pers3 loc3)(necesita pers3 comida)
(necesita pers3 medicina)
	(persona-en pers4 loc4)
	(persona-en pers5 loc5)(necesita pers5 medicina)

	(= (fly-cost deposito loc1) 17)
	(= (fly-cost deposito loc2) 25)
	(= (fly-cost deposito loc3) 14)
	(= (fly-cost deposito loc4) 30)
	(= (fly-cost deposito loc5) 38)
	(= (fly-cost loc1 deposito) 17)
	(= (fly-cost loc1 loc2) 9)
	(= (fly-cost loc1 loc3) 6)
	(= (fly-cost loc1 loc4) 15)
	(= (fly-cost loc1 loc5) 22)
	(= (fly-cost loc2 deposito) 25)
	(= (fly-cost loc2 loc1) 9)
	(= (fly-cost loc2 loc3) 13)
	(= (fly-cost loc2 loc4) 12)
	(= (fly-cost loc2 loc5) 14)
	(= (fly-cost loc3 deposito) 14)
	(= (fly-cost loc3 loc1) 6)
	(= (fly-cost loc3 loc2) 13)
	(= (fly-cost loc3 loc4) 16)
	(= (fly-cost loc3 loc5) 26)
	(= (fly-cost loc4 deposito) 30)
	(= (fly-cost loc4 loc1) 15)
	(= (fly-cost loc4 loc2) 12)
	(= (fly-cost loc4 loc3) 16)
	(= (fly-cost loc4 loc5) 16)
	(= (fly-cost loc5 deposito) 38)
	(= (fly-cost loc5 loc1) 22)
	(= (fly-cost loc5 loc2) 14)
	(= (fly-cost loc5 loc3) 26)
	(= (fly-cost loc5 loc4) 16)

	(cajas-en-contenedor k1 n0)

	(cero n0) 
	(siguiente n0 n1) 
	(siguiente n1 n2) 
	(siguiente n2 n3) 
	(siguiente n3 n4)	(= (total-cost) 0)
)
(:goal (and
	(dron-en dron1 deposito)
	(tiene pers1 medicina)
	(tiene pers2 comida)
	(tiene pers3 comida)
	(tiene pers3 medicina)
	(tiene pers5 medicina)
	))
(:metric minimize (total-cost)))
