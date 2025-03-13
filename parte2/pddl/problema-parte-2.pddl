(define (problem problema-2)
  (:domain dominio-drones-2)
  
  (:objects
    d1 - dron
    p1 p2 p3 p4 - persona
    deposito l1 l2 l3 l4 - localizacion
    c1 c2 c3 c4 c5 c6 c7 - caja
    comida medicina agua - contenido
    k1 - contenedor)

  (:init
    (dron-en d1 deposito)
    (dron-libre d1)
    (en-deposito deposito)
    (contenedor-libre k1)

    (caja-en c1 deposito) (contiene c1 comida)
    (caja-en c2 deposito) (contiene c2 medicina)
    (caja-en c3 deposito) (contiene c3 comida)
    (caja-en c4 deposito) (contiene c4 comida)
    (caja-en c5 deposito) (contiene c5 medicina)
    (caja-en c6 deposito) (contiene c6 medicina)
    (caja-en c7 deposito) (contiene c7 comida)

    (= (fly-cost deposito deposito) 1 )
    (= (fly-cost deposito l1) 30)
    (= (fly-cost deposito l2) 20)
    (= (fly-cost deposito l3) 15)
    (= (fly-cost deposito l4) 10)

    (= (fly-cost l1 l1) 1)
    (= (fly-cost l1 l2) 12)
    (= (fly-cost l1 l3) 19)
    (= (fly-cost l1 l4) 14)
    (= (fly-cost l2 l1) 15)
    (= (fly-cost l2 l2) 1)
    (= (fly-cost l2 l3) 20)
    (= (fly-cost l2 l4) 41)
    (= (fly-cost l3 l1) 26)
    (= (fly-cost l3 l2) 43)
    (= (fly-cost l3 l3) 1)
    (= (fly-cost l3 l4) 25)
    (= (fly-cost l4 l1) 21)
    (= (fly-cost l4 l2) 32)
    (= (fly-cost l4 l3) 47)
    (= (fly-cost l4 l4) 1)
    (= (total-cost) 0)

    (= (cajas-en-contenedor k1) 0)
    (= (limite-contenedor k1) 4)
    (= (combustible d1) 50)
    (= (max-combustible) 100)
  )

  (:goal 
    (and
      (tiene p1 comida)
      (tiene p2 medicina)
      (tiene p3 comida)
      (tiene p4 comida)))

  (:metric minimize (total-cost))
)
