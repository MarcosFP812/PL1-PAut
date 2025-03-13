(define (problem drone_problem_d1_l3_p3_c3_g3_ct2)
(:domain dominio-drones-2)
(:objects
	dron1 - dron
	deposito loc1 loc2 loc3 - localizacion
	caja1 caja2 caja3 - caja
	comida medicina - contenido
	pers1 pers2 pers3 - persona
	k1 k2 k3 - contenedor
)
(:init
	(dron-en dron1 deposito)
	(dron-libre dron1)

	(en-deposito deposito) 
	(contenedor-libre k1)
	(contenedor-libre k2)
	(contenedor-libre k3)
	(caja-en caja1 deposito) (contiene caja1 comida)
	(caja-en caja2 deposito) (contiene caja2 comida)
	(caja-en caja3 deposito)(contiene caja3 medicina)
	(persona-en pers1 loc1)(necesita pers1 comida)
(necesita pers1 medicina)
	(persona-en pers2 loc2)	(persona-en pers3 loc3)(necesita pers3 comida)
	(= (fly-cost deposito loc1) 14)
	(= (fly-cost deposito loc2) 28)
	(= (fly-cost deposito loc3) 31)
	(= (fly-cost loc1 deposito) 14)
	(= (fly-cost loc1 loc2) 27)
	(= (fly-cost loc1 loc3) 29)
	(= (fly-cost loc2 deposito) 28)
	(= (fly-cost loc2 loc1) 27)
	(= (fly-cost loc2 loc3) 6)
	(= (fly-cost loc3 deposito) 31)
	(= (fly-cost loc3 loc1) 29)
	(= (fly-cost loc3 loc2) 6)
	(= (cajas-en-contenedor k1) 0)
	(= (cajas-en-contenedor k2) 0)
	(= (cajas-en-contenedor k3) 0)
	(= (limite-contenedor) 4)
	(= (total-cost) 0)
	(= (combustible dron1) 50)
	(= (max-combustible) 100)
)
(:goal (and
	(dron-en dron1 deposito)
	(tiene pers1 comida)
	(tiene pers1 medicina)
	(tiene pers3 comida)
	))
(:metric minimize (total-cost)))
