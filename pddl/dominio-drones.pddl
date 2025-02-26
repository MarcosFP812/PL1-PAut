(define (domain dominio-drones)
  (:requirements :strips :typing)

  (:types
    dron persona localizacion caja contenido brazo)

  (:predicates
    (dron-en ?d - dron ?l - localizacion)
    (caja-en ?c - caja ?l - localizacion)
    (persona-en ?p - persona ?l - localizacion)
    (sostiene ?d - dron ?b - brazo ?c - caja)
    (brazo-libre ?d - dron ?b - brazo)
    (necesita ?p - persona ?t - contenido)
    (tiene ?p - persona ?t - contenido)
    (contiene ?c - caja ?t - contenido))


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
    )
    :effect (
      and (sostiene ?d ?b ?c) 
      (not (caja-en ?c ?l)) 
      (not (brazo-libre ?d ?b))
    )
  )


  (:action volar
    :parameters (
      ?d - dron 
      ?from - localizacion 
      ?to - localizacion
    )
    :precondition (
      dron-en ?d ?from
    )
    :effect (
      and (not (dron-en ?d ?from)) 
      (dron-en ?d ?to)
    )
  )


  (:action entregar
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
    )
  )
)
