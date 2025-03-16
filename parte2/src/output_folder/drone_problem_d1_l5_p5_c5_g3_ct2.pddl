(define (problem drone_problem_d1_l5_p5_c5_g3_ct2)
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
  (contenedor-en k1 deposito)
  (contenedor-libre k1)
  (cajas-en-contenedor k1 n0)
  (caja-en caja1 deposito)
  (caja-libre caja1)
  (contiene caja1 comida)
  (caja-en caja2 deposito)
  (caja-libre caja2)
  (contiene caja2 comida)
  (caja-en caja3 deposito)
  (caja-libre caja3)
  (contiene caja3 comida)

  (caja-en caja4 deposito)
  (caja-libre caja4)
  (contiene caja4 medicina)
  (caja-en caja5 deposito)
  (caja-libre caja5)
  (contiene caja5 medicina)

  (persona-en pers1 loc1)

  (persona-en pers2 loc2)

  (persona-en pers3 loc3)

  (persona-en pers4 loc4)
  (necesita pers4 comida)
  (necesita pers4 medicina)

  (persona-en pers5 loc5)
  (necesita pers5 comida)

  (= (fly-cost deposito deposito) 1)
  (= (fly-cost deposito loc1) 20)
  (= (fly-cost deposito loc2) 34)
  (= (fly-cost deposito loc3) 11)
  (= (fly-cost deposito loc4) 22)
  (= (fly-cost deposito loc5) 30)
  (= (fly-cost loc1 deposito) 20)
  (= (fly-cost loc1 loc1) 1)
  (= (fly-cost loc1 loc2) 26)
  (= (fly-cost loc1 loc3) 10)
  (= (fly-cost loc1 loc4) 9)
  (= (fly-cost loc1 loc5) 24)
  (= (fly-cost loc2 deposito) 34)
  (= (fly-cost loc2 loc1) 26)
  (= (fly-cost loc2 loc2) 1)
  (= (fly-cost loc2 loc3) 32)
  (= (fly-cost loc2 loc4) 17)
  (= (fly-cost loc2 loc5) 6)
  (= (fly-cost loc3 deposito) 11)
  (= (fly-cost loc3 loc1) 10)
  (= (fly-cost loc3 loc2) 32)
  (= (fly-cost loc3 loc3) 1)
  (= (fly-cost loc3 loc4) 16)
  (= (fly-cost loc3 loc5) 28)
  (= (fly-cost loc4 deposito) 22)
  (= (fly-cost loc4 loc1) 9)
  (= (fly-cost loc4 loc2) 17)
  (= (fly-cost loc4 loc3) 16)
  (= (fly-cost loc4 loc4) 1)
  (= (fly-cost loc4 loc5) 15)
  (= (fly-cost loc5 deposito) 30)
  (= (fly-cost loc5 loc1) 24)
  (= (fly-cost loc5 loc2) 6)
  (= (fly-cost loc5 loc3) 28)
  (= (fly-cost loc5 loc4) 15)
  (= (fly-cost loc5 loc5) 1)

  (cero n0)
  (siguiente n0 n1)
  (siguiente n1 n2)
  (siguiente n2 n3)
  (siguiente n3 n4)
  (= (total-cost) 0)
)

(:goal (and
  (dron-en dron1 deposito)
  (tiene pers4 comida)
  (tiene pers4 medicina)
  (tiene pers5 comida)
))

(:metric minimize (total-cost))
)
