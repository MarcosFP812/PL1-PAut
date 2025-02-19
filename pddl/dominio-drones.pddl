(define (domain dominio-drones)
  (:requirements :strips :typing)

  (:types
    dron persona localizacion caja contenido)

  (:predicates
    (dron-en ?d - dron ?l - localizacion)
    (caja-en ?c - caja ?l - localizacion)
    (persona-en ?p - persona ?l - localizacion)
    (sostiene-izq ?d - dron ?c - caja)
    (sostiene-der ?d - dron ?c - caja)
    (brazo-izq-libre ?d - dron)
    (brazo-der-libre ?d - dron)
    (necesita ?p - persona ?t - contenido)
    (tiene ?p - persona ?t - contenido)
    (contiene ?c - caja ?t - contenido))


  (:action coger-izq
    :parameters (
      ?d - dron 
      ?c - caja 
      ?l - localizacion
    )
    :precondition (
      and (dron-en ?d ?l) 
      (caja-en ?c ?l) 
      (brazo-izq-libre ?d)
    )
    :effect (
      and (sostiene-izq ?d ?c) 
      (not (caja-en ?c ?l)) 
      (not (brazo-izq-libre ?d))
    )
  )


  (:action coger-der
    :parameters (
      ?d - dron 
      ?c - caja 
      ?l - localizacion
    )
    :precondition (
      and (dron-en ?d ?l) 
      (caja-en ?c ?l) 
      (brazo-der-libre ?d)
    )
    :effect (
      and (sostiene-der ?d ?c) 
      (not (caja-en ?c ?l)) 
      (not (brazo-der-libre ?d))
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


  (:action entregar-izq
    :parameters (
      ?d - dron 
      ?c - caja 
      ?p - persona 
      ?l - localizacion 
      ?t - contenido
    )
    :precondition (
      and (sostiene-izq ?d ?c) 
      (dron-en ?d ?l) 
      (persona-en ?p ?l)              
      (contiene ?c ?t) 
      (necesita ?p ?t)
    )
    :effect (
      and (tiene p1 comida) 
      (not (sostiene-izq ?d ?c)) 
      (not (necesita ?p ?t)) 
      (brazo-izq-libre ?d)
    )
  )


  (:action entregar-der
    :parameters (
      ?d - dron 
      ?c - caja 
      ?p - persona 
      ?l - localizacion 
      ?t - contenido
    )
    :precondition (
      and (sostiene-der ?d ?c) 
      (dron-en ?d ?l) 
      (persona-en ?p ?l)
      (contiene ?c ?t) 
      (necesita ?p ?t)
    )
    :effect (
      and (tiene ?p ?t) 
      (not (sostiene-der ?d ?c)) 
      (not (necesita ?p ?t)) 
      (brazo-der-libre ?d)
    )
  )
)
