(define (domain dominio-drones-2)
  (:requirements :strips :typing :action-costs)

  (:types
    dron persona localizacion caja contenido brazo contenedor)

  (:predicates
    (dron-en ?d - dron ?l - localizacion)
    (caja-en ?c - caja ?l - localizacion)
    (persona-en ?p - persona ?l - localizacion)
    (sostiene ?d - dron ?b - brazo ?c - caja)
    (brazo-libre ?d - dron ?b - brazo)

    (brazos-libres ?d - dron)

    (necesita ?p - persona ?t - contenido)
    (tiene ?p - persona ?t - contenido)
    (contiene ?c - caja ?t - contenido)

    (tiene-contenedor ?d - dron ?k - contenedor)
    (en-contenedor ?d - dron ?k - contenedor ?c - caja)
  )

  (:functions
    (brazos-ocupados ?d - dron)
    (cajas-en-contenedor ?k - contenedor)
    (limite-contenedor)
    (fly-cost ?l1 ?l2 - localizacion)
    (combustible ?d)
    (max-combustible)
    (total-cost)
  )

  (:action coger
    :parameters (
      ?d - dron 
      ?c - caja 
      ?l - localizacion
      ?b - brazo
    )
    :precondition (
      and (dron-en ?d ?l) 
      (caja-en ?c ?l) 
      (brazo-libre ?d ?b)
      (brazos-libres ?d)
    )
    :effect (
      and (sostiene ?d ?b ?c) 
      (not (caja-en ?c ?l)) 
      (not (brazo-libre ?d ?b))
      (increase (brazos-ocupados ?d) 1)
    )
  )

  (:action coger-contenedor
    :parameters (
      ?d - dron 
      ?k - contenedor 
    )
    :precondition (
      and (= (brazos-ocupados ?d) 0)
      (= (cajas-en-contenedor ?k) 0)
    )
    :effect (and
      (tiene-contenedor ?d ?k)
      (not (brazos-libres ?d))
    )
  )

  (:action dejar-contenedor
    :parameters (
      ?d - dron 
      ?k - contenedor 
    )
    :precondition (and
      (tiene-contenedor ?d ?k)
      (= (cajas-en-contenedor ?k) 0)
    )
    :effect (and
      (not (tiene-contenedor ?d ?k))
      (brazos-libres ?d)
    )
  )

  (:action meter
    :parameters (
      ?d - dron 
      ?c - caja 
      ?l - localizacion
      ?k - contenedor
    )
    :precondition (
      and (dron-en ?d ?l) 
      (tiene-contenedor ?d ?k)
      (caja-en ?c ?l) 
      (< (limite-contenedor) (cajas-en-contenedor ?k))
    )
    :effect (
      and (en-contenedor ?d ?k ?c) 
      (not (caja-en ?c ?l)) 
      (not (brazos-libres ?d))
      (increase (cajas-en-contenedor ?d) 1)
    )
  )


  (:action volar
    :parameters (
      ?d - dron 
      ?from - localizacion 
      ?to - localizacion
    )
    :precondition (and
      (dron-en ?d ?from)
      (>= (combustible ?d) (fly-cost ?from ?to))
    )
    :effect (
      and (not (dron-en ?d ?from)) 
      (dron-en ?d ?to)
      (increase (total-cost) (fly-cost ?from ?to))
    )
  )

  (:action repostar
    :parameters (
      ?d - dron
    )
    :precondition ( 
      < (combustible ?d) (max-combustible)
    )
    :effect (and
      (assign (combustible ?d) (max-combustible))
    )
  )


  (:action entregar-brazo
    :parameters (
      ?d - dron 
      ?c - caja 
      ?b - brazo
      ?p - persona 
      ?l - localizacion 
      ?t - contenido
    )
    :precondition (
      and (sostiene ?d ?b ?c) 
      (dron-en ?d ?l) 
      (persona-en ?p ?l)              
      (contiene ?c ?t) 
      (necesita ?p ?t)
    )
    :effect (
      and (tiene ?p ?t) 
      (not (sostiene ?d ?b ?c)) 
      (not (necesita ?p ?t)) 
      (brazo-libre ?d ?b)
      (decrease (brazos-ocupados ?d) 1)
    )
  )

  (:action entregar-contenedor
    :parameters (
      ?d - dron 
      ?c - caja 
      ?k - contenedor
      ?p - persona 
      ?l - localizacion 
      ?t - contenido
    )
    :precondition (
      and (en-contenedor ?d ?k ?c) 
      (dron-en ?d ?l) 
      (persona-en ?p ?l)              
      (contiene ?c ?t) 
      (necesita ?p ?t)
    )
    :effect (
      and (tiene ?p ?t) 
      (not (en-contenedor ?d ?k ?c)) 
      (not (necesita ?p ?t))
      (decrease (cajas-en-contenedor ?k) 1)
    )
  )
)
