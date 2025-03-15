(define (problem problema-3)
  (:domain dominio-drones-3)
  
  (:objects
    d1 d2 d3 - dron
    p1 p2 p3 p4 - persona
    deposito l1 l2 l3 l4 - localizacion
    c1 c2 c3 c4 c5 c6 c7 - caja
    comida medicina agua - contenido
    k1 k2 k3 - contenedor
    n0 n1 n2 n3 n4 - num)

  (:init
    (cero n0)
    (siguiente n0 n1)
    (siguiente n1 n2)
    (siguiente n2 n3)
    (siguiente n3 n4)
    
    (dron-en d1 deposito)
    (dron-en d2 deposito)
    (dron-en d3 deposito)
    (dron-libre d1)
    (dron-libre d2)
    (dron-libre d3)
    (en-deposito deposito)
    (contenedor-libre k1)
    (contenedor-libre k2)
    (contenedor-libre k3)

    (caja-en c1 deposito) (contiene c1 comida)
    (caja-en c2 deposito) (contiene c2 medicina)
    (caja-en c3 deposito) (contiene c3 comida)
    (caja-en c4 deposito) (contiene c4 comida)
    (caja-en c5 deposito) (contiene c5 medicina)
    (caja-en c6 deposito) (contiene c6 medicina)
    (caja-en c7 deposito) (contiene c7 comida)
    
    (persona-en p1 l1)
    (persona-en p2 l2)
    (persona-en p3 l3)
    (persona-en p4 l4)
    
    (necesita p1 comida)
    (necesita p2 medicina)
    (necesita p3 comida)
    (necesita p4 comida)
    
    (cajas-en-contenedor k1 n0)
    (cajas-en-contenedor k2 n0)
    (cajas-en-contenedor k3 n0)
    (caja-libre c1)
    (caja-libre c2)
    (caja-libre c3)
    (caja-libre c4)
    (caja-libre c5)
    (caja-libre c6)
    (caja-libre c7)
    (dron-sin-caja d1)
    (dron-sin-caja d2)
    (dron-sin-caja d3)
    
    (= (fly-cost deposito deposito) 0)
    (= (fly-cost l1 l1) 0)
    (= (fly-cost l2 l2) 0)
    (= (fly-cost l3 l3) 0)
    (= (fly-cost l4 l4) 0)

    (= (fly-cost l1 deposito) 30)
    (= (fly-cost l2 deposito) 20)
    (= (fly-cost l3 deposito) 15)
    (= (fly-cost l4 deposito) 10)
    (= (fly-cost deposito l1) 30)
    (= (fly-cost deposito l2) 20)
    (= (fly-cost deposito l3) 15)
    (= (fly-cost deposito l4) 10)

    (= (fly-cost l1 l2) 12)
    (= (fly-cost l1 l3) 19)
    (= (fly-cost l1 l4) 14)
    (= (fly-cost l2 l1) 15)
    (= (fly-cost l2 l3) 20)
    (= (fly-cost l2 l4) 41)
    (= (fly-cost l3 l1) 26)
    (= (fly-cost l3 l2) 43)
    (= (fly-cost l3 l4) 25)
    (= (fly-cost l4 l1) 21)
    (= (fly-cost l4 l2) 32)
    (= (fly-cost l4 l3) 47)
    (= (total-cost) 0)
  )

  (:goal 
    (and
      (dron-en d1 deposito)
      (dron-en d2 deposito)
      (dron-en d3 deposito)
      (tiene p1 comida)
      (tiene p2 medicina)
      (tiene p3 comida)
      (tiene p4 comida)))

  (:metric minimize (total-cost))
)