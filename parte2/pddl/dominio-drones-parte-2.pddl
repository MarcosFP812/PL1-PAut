(define (domain dominio-drones-parte2-funciones)
  (:requirements
    :strips 
    :typing 
    :negative-preconditions 
    :numeric-fluents
    :action-costs
  )
  (:types dron localizacion caja contenido persona contenedor)

  (:predicates
    (dron-en ?d - dron ?loc - localizacion)
    (persona-en ?p - persona ?loc - localizacion)
    (caja-en ?c - caja ?loc - localizacion)

    (contiene ?c - caja ?x - contenido)

    (necesita ?p - persona ?x - contenido)
    (tiene ?p - persona ?x - contenido)

    (dron-libre ?d - dron)
    (dron-sin-caja ?d - dron)
    (caja-libre ?c - caja)

    (contenedor-en ?k - contenedor ?loc - localizacion)
    ;; Podrías tener algún predicado más si quieres, ej. (contenedor-libre ?k) etc.
  )

  (:functions
    ;; Capacidad máxima del contenedor: se asigna con (= (capacity k1) 4) en :init
    (capacity ?k - contenedor) - number
    ;; Cuántas cajas están actualmente en el contenedor
    (used ?k - contenedor) - number

    (fly-cost ?from - localizacion ?to - localizacion) - number
    (total-cost) - number
  )

  ;;-------------------------
  ;; ACCIONES
  ;;-------------------------

  ;; (1) COGER-CAJA (igual que antes)
  (:action coger-caja
    :parameters (?d - dron ?c - caja ?loc - localizacion)
    :precondition (and
      (dron-en ?d ?loc)
      (caja-en ?c ?loc)
      (dron-libre ?d)
      (dron-sin-caja ?d)
      (caja-libre ?c)
    )
    :effect (and
      (not (caja-libre ?c))
      (not (dron-sin-caja ?d))
      (increase (total-cost) 1)
    )
  )

  ;; (2) DEJAR-CAJA
  (:action dejar-caja
    :parameters (?d - dron ?c - caja ?loc - localizacion)
    :precondition (and
      (dron-en ?d ?loc)
      (not (dron-sin-caja ?d)) 
      (not (caja-libre ?c))
    )
    :effect (and
      (caja-libre ?c)
      (dron-sin-caja ?d)
      (increase (total-cost) 1)
    )
  )

  ;; (3) METER-CAJA-EN-CONTENEDOR usando funciones 'used' y 'capacity'
  (:action meter-caja-en-contenedor
    :parameters (?d - dron ?c - caja ?k - contenedor ?loc - localizacion)
    :precondition (and
      (dron-en ?d ?loc)
      (contenedor-en ?k ?loc)
      (not (dron-sin-caja ?d))
      (not (caja-libre ?c))
      ;; chequea que no supere la capacidad
      (< (used ?k) (capacity ?k))
    )
    :effect (and
      ;; dron suelta caja en contenedor
      (not (dron-sin-caja ?d))
      (dron-sin-caja ?d)
      (caja-libre ?c)
      ;; incrementa la ocupación
      (increase (used ?k) 1)
      (increase (total-cost) 1)
    )
  )

  ;; (4) SACAR-CAJA-DE-CONTENEDOR
  (:action sacar-caja-de-contenedor
    :parameters (?d - dron ?c - caja ?k - contenedor ?loc - localizacion)
    :precondition (and
      (dron-en ?d ?loc)
      (contenedor-en ?k ?loc)
      (dron-libre ?d)
      (dron-sin-caja ?d)
      ;; Para poder sacar, used(k) > 0
      (> (used ?k) 0)
    )
    :effect (and
      (not (dron-libre ?d))
      (not (dron-sin-caja ?d))
      (not (caja-libre ?c))
      (decrease (used ?k) 1)
      (increase (total-cost) 1)
    )
  )

  ;; (5) ENTREGAR-CAJA
  (:action entregar-caja
    :parameters (?d - dron ?c - caja ?p - persona ?x - contenido ?loc - localizacion)
    :precondition (and
      (dron-en ?d ?loc)
      (persona-en ?p ?loc)
      (contiene ?c ?x)
      (necesita ?p ?x)
      (not (dron-sin-caja ?d))
      (not (caja-libre ?c))
    )
    :effect (and
      (tiene ?p ?x)
      (not (necesita ?p ?x))
      (caja-libre ?c)
      (dron-sin-caja ?d)
      (increase (total-cost) 1)
    )
  )

  ;; (6) VOLAR
  (:action volar
    :parameters (?d - dron ?from ?to - localizacion)
    :precondition (and
      (dron-en ?d ?from)
      (not (= ?from ?to))
    )
    :effect (and
      (not (dron-en ?d ?from))
      (dron-en ?d ?to)
      (increase (total-cost) (fly-cost ?from ?to))
    )
  )
)
