(define (problem problema)
  (:domain dominio-drones)
  
  (:objects
    d1 - dron
    p1 p2 p3 p4 - persona
    deposito l1 l2 l3 l4 - localizacion
    c1 c2 c3 c4 c5 c6 c7 - caja
    comida medicina agua - contenido
  )

  (:init
    ;; Ubicación inicial del dron y las cajas en el depósito
    (dron-en d1 deposito)
    (brazo-izq-libre d1)
    (brazo-der-libre d1)

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
    (persona-en p4 l4) (necesita p4 comida))

  (:goal 
    (and
      (tiene p1 comida)
      (tiene p2 medicina)
      (tiene p3 comida)
      (tiene p4 comida)))
)
