(define (domain dominio-drones-parte2)
  (:requirements :strips :typing :action-costs :numeric-fluents)
  ;; IMPORTANTE: no usamos :negative-preconditions
  ;; :numeric-fluents permite funciones de coste.

  (:types
    dron persona caja contenedor localizacion contenido num
  )

  ;; -----------------------------------------
  ;; PREDICADOS
  ;; -----------------------------------------
  (:predicates
    ;; Dónde está el dron
    (dron-en ?d - dron ?l - localizacion)

    ;; El dron llevando (cogida) una caja
    (dron-lleva ?d - dron ?c - caja)

    ;; El contenedor y su conteo de cajas (capacidad)
    (contenedor-en ?k - contenedor ?l - localizacion)
    (cajas-en-contenedor ?k - contenedor ?n - num)

    ;; La caja en el suelo
    (caja-en ?c - caja ?l - localizacion)
    ;; Tipo de contenido de la caja
    (contiene ?c - caja ?t - contenido)

    ;; Personas y sus necesidades
    (persona-en ?p - persona ?l - localizacion)
    (necesita ?p - persona ?t - contenido)
    (tiene ?p - persona ?t - contenido)

    ;; Numeritos discretos (0..4) para la capacidad del contenedor
    (cero ?n - num)
    (siguiente ?n1 - num ?n2 - num)
  )

  ;; -----------------------------------------
  ;; FUNCIONES (fluents)
  ;; -----------------------------------------
  (:functions
    (total-cost)
    (fly-cost ?l1 - localizacion ?l2 - localizacion)
  )

  ;; -----------------------------------------
  ;; ACCIONES
  ;; -----------------------------------------

  ;; 1) COGER-CAJA: El dron toma una caja que esté en el suelo
  (:action coger-caja
    :parameters (?d - dron ?c - caja ?l - localizacion)
    :precondition (and
      (dron-en ?d ?l)
      (caja-en ?c ?l) ;; la caja está en el suelo
    )
    :effect (and
      (dron-lleva ?d ?c)
      (not (caja-en ?c ?l))
      (increase (total-cost) 1)
    )
  )

  ;; 2) PONER-CAJA-EN-TRANSPORTADOR: Dron deja su caja en el contenedor
  (:action poner-caja-en-transportador
    :parameters (?d - dron ?c - caja ?k - contenedor ?l - localizacion ?n - num ?n2 - num)
    :precondition (and
      (dron-en ?d ?l)
      (dron-lleva ?d ?c)
      (contenedor-en ?k ?l)
      (cajas-en-contenedor ?k ?n)
      (siguiente ?n ?n2)  ;; capacidad: podemos pasar de n a n2
    )
    :effect (and
      (not (dron-lleva ?d ?c))
      (caja-en-contenedor ?c ?k)
      (not (cajas-en-contenedor ?k ?n))
      (cajas-en-contenedor ?k ?n2)
      (increase (total-cost) 1)
    )
  )

  ;; 3) COGER-CAJA-DEL-TRANSPORTADOR: Dron toma la caja del contenedor
  (:action coger-caja-del-transportador
    :parameters (?d - dron ?c - caja ?k - contenedor ?l - localizacion ?n - num ?n2 - num)
    :precondition (and
      (dron-en ?d ?l)
      (contenedor-en ?k ?l)
      (caja-en-contenedor ?c ?k)
      (cajas-en-contenedor ?k ?n)
      (siguiente ?n2 ?n) ;; pasamos de n a n2 extrayendo 1 caja
    )
    :effect (and
      (dron-lleva ?d ?c)
      (not (caja-en-contenedor ?c ?k))
      (not (cajas-en-contenedor ?k ?n))
      (cajas-en-contenedor ?k ?n2)
      (increase (total-cost) 1)
    )
  )

  ;; 4) ENTREGAR-CAJA a la persona
  (:action entregar-caja
    :parameters (?d - dron ?c - caja ?p - persona ?l - localizacion ?t - contenido)
    :precondition (and
      (dron-en ?d ?l)
      (dron-lleva ?d ?c)
      (persona-en ?p ?l)
      (contiene ?c ?t)
      (necesita ?p ?t)
    )
    :effect (and
      (tiene ?p ?t)
      (not (necesita ?p ?t))
      (not (dron-lleva ?d ?c))
      (caja-en ?c ?l)
      (increase (total-cost) 1)
    )
  )

  ;; 5) MOVER-TRANSPORTADOR (equivalente a volar con él)
  (:action mover-transportador
    :parameters (?d - dron ?k - contenedor ?origen - localizacion ?dest - localizacion)
    :precondition (and
      (dron-en ?d ?origen)
      (contenedor-en ?k ?origen)
    )
    :effect (and
      (not (dron-en ?d ?origen))
      (not (contenedor-en ?k ?origen))
      (dron-en ?d ?dest)
      (contenedor-en ?k ?dest)
      (increase (total-cost) (fly-cost ?origen ?dest))
    )
  )

  ;; -----------------------------------------
  ;; Métrica para minimizar el coste total
  ;; -----------------------------------------
  (:metric minimize (total-cost))
)
