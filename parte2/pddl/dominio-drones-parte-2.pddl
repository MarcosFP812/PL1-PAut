(define (domain dominio-drones-2)
  (:requirements :strips :typing :action-costs)

  (:types
    dron persona localizacion caja contenido contenedor num)

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
    (necesita ?p - persona ?t - contenido)
    
    (siguiente ?n1 - num ?n2 - num)
    (cajas-en-contenedor ?k - contenedor ?n - num)
    (cero ?n - num)
  )

  (:functions
    (fly-cost ?l1 - localizacion ?l2 - localizacion)
    (total-cost)
  )

  (:action coger
    :parameters (
      ?d - dron 
      ?k - contenedor 
      ?l - localizacion
      ?n - num
    )
    :precondition (and
      (dron-en ?d ?l)
      (en-deposito ?l)
      (dron-libre ?d)
      (contenedor-libre ?k)
      (cero ?n)
    )
    :effect (and
      (tiene-contenedor ?d ?k)
      (not (dron-libre ?d))
      (not (contenedor-libre ?k))
      (cajas-en-contenedor ?k ?n)
    )
  )

  (:action dejar
    :parameters (
      ?d - dron 
      ?k - contenedor 
      ?l - localizacion
      ?n1 - num
    )
    :precondition (and
      (dron-en ?d ?l)
      (en-deposito ?l)
      (tiene-contenedor ?d ?k)
      (cajas-en-contenedor ?k ?n)
      (cero ?n)
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
      ?actual ?sig - numero
    )
    :precondition (and
      (dron-en ?d ?l) 
      (tiene-contenedor ?d ?k)
      (caja-en ?c ?l) 
      (siguiente ?n1 ?n2)
      (cajas-en-contenedor ?k ?n1)
    )
    :effect (and
      (en-contenedor ?k ?c) 
      (not (caja-en ?c ?l)) 
      (not (cajas-en-contenedor ?k ?n1))
      (cajas-en-contenedor ?k ?n2)
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
    )
    :effect (and
      (not (dron-en ?d ?from)) 
      (dron-en ?d ?to)
      (increase (total-cost) (fly-cost ?from ?to))
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
      (siguiente ?n1 ?n2)
      (cajas-en-contenedor ?k ?n2)
    )
    :effect (and
      (tiene ?p ?t)
      (not (necesita ?p ?t))
      (not (en-contenedor ?k ?c)) 
      (not (contiene ?c ?t))
      (not (cajas-en-contenedor ?k ?n2))
      (cajas-en-contenedor ?k ?n1)
    )
  )
)
