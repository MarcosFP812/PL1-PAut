(define (problem problema-3)
  (:domain dominio-drones-3)
  
  (:objects
    d1 - dron
    p1 p2 p3 p4 - persona
    deposito l1 l2 l3 l4 - localizacion
    c1 c2 c3 c4 c5 c6 c7 - caja
    comida medicina agua - contenido
    k1 - contenedor)

  (:init
    ;; Ubicación inicial del dron y las cajas en el depósito
    (dron-en d1 deposito)
    (dron-libre d1)

    (en-deposito deposito)

    ;;Ubicacion contenedores y cajas
    (contenedor-libre k1)

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

    (= (cajas-en-contenedor k1) 0)
    (= (limite-contenedor) 4)
    (= (combustible d1) 50)
    (= (max-combustible) 100)
  )

  (:goal 
    (and
      (tiene p1 comida)
      (tiene p2 medicina)
      (tiene p3 comida)
      (tiene p4 comida))
  )

  (:metric minimize (fly-cost))
)
