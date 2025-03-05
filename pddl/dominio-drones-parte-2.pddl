(define (domain dominio-drones-2)
  (:requirements :strips :typing :action-costs)

  (:types
    dron persona localizacion caja contenido contenedor)

  (:predicates
    (dron-en ?d - dron ?l - localizacion)
    (caja-en ?c - caja ?l - localizacion)
    (persona-en ?p - persona ?l - localizacion)

    (necesita ?p - persona ?t - contenido)
    (tiene ?p - persona ?t - contenido)
    (contiene ?c - caja ?t - contenido)

    (tiene-contenedor ?d - dron ?k - contenedor)
    (en-contenedor ?d - dron ?k - contenedor ?c - caja)
    (dron-libre ?d - dron)
  )

  (:functions
    (cajas-en-contenedor ?k - contenedor)
    (limite-contenedor)
    (fly-cost ?l1 ?l2 - localizacion)
    (combustible ?d)
    (max-combustible)
    (total-cost)
  )

  (:action coger-contenedor
    :parameters (
      ?d - dron 
      ?k - contenedor 
    )
    :precondition (and
      (= (cajas-en-contenedor ?k) 0)
      (dron-libre ?d)
    )
    :effect (and
      (tiene-contenedor ?d ?k)
      (not (dron-libre ?d))
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
      (dron-libre ?d)
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
      (< (cajas-en-contenedor ?k) (limite-contenedor))
    )
    :effect (
      and (en-contenedor ?d ?k ?c) 
      (not (caja-en ?c ?l)) 
      (increase (cajas-en-contenedor ?k) 1)
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
