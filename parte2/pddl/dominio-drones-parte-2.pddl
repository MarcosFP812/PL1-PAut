(define (domain dominio-drones-2)
  (:requirements :strips :numeric-fluents :typing :action-costs)

  (:types
    dron persona localizacion caja contenido contenedor)

  (:predicates
    (dron-en ?d - dron ?l - localizacion)
    (caja-en ?c - caja ?l - localizacion)
    (persona-en ?p - persona ?l - localizacion)
    (en-deposito ?l - localizacion)

    (tiene ?p - persona ?t - contenido)
    (contiene ?c - caja ?t - contenido)
    (contenedor-libre ?k - contenedor) 

    (tiene-contenedor ?d - dron ?k - contenedor)
    (en-contenedor ?k - contenedor ?c - caja)
    (dron-libre ?d - dron)
  )

  (:functions
    (cajas-en-contenedor ?k - contenedor)
    (limite-contenedor ?k - contenedor)
    (fly-cost ?l1 - localizacion ?l2 - localizacion)
    (combustible ?d - dron)
    (max-combustible)
    (total-cost)
  )

  (:action coger
    :parameters (
      ?d - dron 
      ?k - contenedor 
      ?l - localizacion
    )
    :precondition (and
      (dron-en ?d ?l)
      (en-deposito ?l)
      (dron-libre ?d)
      (contenedor-libre ?k)
    )
    :effect (and
      (tiene-contenedor ?d ?k)
      (not (dron-libre ?d))
      (not (contenedor-libre ?k))
      (assign (cajas-en-contenedor ?k) 0)
    )
  )

  (:action dejar
    :parameters (
      ?d - dron 
      ?k - contenedor 
      ?l - localizacion
    )
    :precondition (and
      (dron-en ?d ?l)
      (en-deposito ?l)
      (tiene-contenedor ?d ?k)
      (<= (cajas-en-contenedor ?k) 0)
    )
    :effect (and
      (not (tiene-contenedor ?d ?k))
      (dron-libre ?d)
      (contenedor-libre ?k)
    )
  )

  (:action meter
    :parameters (
      ?d - dron 
      ?c - caja 
      ?l - localizacion
      ?k - contenedor
    )
    :precondition (and
      (dron-en ?d ?l) 
      (tiene-contenedor ?d ?k)
      (caja-en ?c ?l) 
      (< (cajas-en-contenedor ?k) (limite-contenedor ?k))
    )
    :effect (and
      (en-contenedor ?k ?c) 
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
    :effect (and
      (not (dron-en ?d ?from)) 
      (dron-en ?d ?to)
      (increase (total-cost) (fly-cost ?from ?to))
      (decrease (combustible ?d) (fly-cost ?from ?to))
    )
  )

  (:action repostar
    :parameters (
      ?d - dron
      ?l - localizacion
    )
    :precondition (and
      (en-deposito ?l)
      (dron-en ?d ?l)
      (< (combustible ?d) (max-combustible))
    )
    :effect (and
      (assign (combustible ?d) (max-combustible))
    )
  )

  (:action entregar
    :parameters (
      ?d - dron 
      ?c - caja 
      ?k - contenedor
      ?p - persona 
      ?l - localizacion 
      ?t - contenido
    )
    :precondition (and
      (dron-en ?d ?l) 
      (persona-en ?p ?l)              
      (contiene ?c ?t)
      (en-contenedor ?k ?c)
    )
    :effect (and
      (tiene ?p ?t)
      (not (necesita ?p ?t))
      (not (en-contenedor ?k ?c)) 
      (not (contiene ?c ?t))
      (decrease (cajas-en-contenedor ?k) 1)
    )
  )
)
