(define (problem problema-2)
  (:domain dominio-drones-2)
  
  (:objects
    d1 - dron
    b1 b2 - brazo
    p1 p2 p3 p4 - persona
    deposito l1 l2 l3 l4 - localizacion
    c1 c2 c3 c4 c5 c6 c7 - caja
    comida medicina agua - contenido)

  (:init
    ;; Ubicación inicial del dron y las cajas en el depósito
    (dron-en d1 deposito)
    (brazo-libre d1 b1)
    (brazo-libre d1 b2)

    (caja-en c1 deposito) (contiene c1 comida)
    (caja-en c2 deposito) (contiene c2 medicina)
    (caja-en c3 deposito) (contiene c3 comida)
    (caja-en c4 deposito) (contiene c4 comida)
    (caja-en c5 deposito) (contiene c5 medicina)
    (caja-en c6 deposito) (contiene c6 medicina)
    (caja-en c7 deposito) (contiene c7 comida)

    ;; Ubicación de las personas y sus necesidades
    (persona-en p1 l1) (necesita p1 comida)
    (persona-en p2 l2) (necesita p2 medicina)
    (persona-en p3 l3) (necesita p3 comida)
    (persona-en p4 l4) (necesita p4 comida)

    ;; Coste vuelo entre localizaciones
    (= (fly-cost l1 l2) 122)
    (= (fly-cost l1 l3) 193)
    (= (fly-cost l1 l4) 140)
    (= (fly-cost l2 l1) 100)
    (= (fly-cost l2 l3) 102)
    (= (fly-cost l2 l4) 141)
    (= (fly-cost l3 l1) 126)
    (= (fly-cost l3 l2) 143)
    (= (fly-cost l3 l4) 125)
    (= (fly-cost l4 l1) 121)
    (= (fly-cost l4 l2) 162)
    (= (fly-cost l4 l3) 147)
  )

  (:goal 
    (and
      (tiene p1 comida)
      (tiene p2 medicina)
      (tiene p3 comida)
      (tiene p4 comida)))

  (:metric minimize (total-cost))
)
