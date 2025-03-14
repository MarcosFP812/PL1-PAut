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
    
    (necesita ?p - persona ?t - contenido)

    (tiene-contenedor ?d - dron ?k - contenedor)
    (en-contenedor ?k - contenedor ?c - caja)
    (dron-libre ?d - dron)
    
    (tiene-caja ?d - dron ?c - caja)
    (caja-libre ?c - caja)
    (dron-sin-caja ?d - dron)
  
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
      ?n - num
    )
    :precondition (and
      (dron-en ?d ?l)
      (en-deposito ?l)
      (tiene-contenedor ?d ?k)
      (cero ?n)
      (cajas-en-contenedor ?k ?n)
    )
    :effect (and
      (not (tiene-contenedor ?d ?k))
      (dron-libre ?d)
      (contenedor-libre ?k)
    )
  )
  
  (:action coger-caja
    :parameters (
      ?d - dron 
      ?c - caja 
      ?l - localizacion
      ?n - num
    )
    :precondition (and
      (dron-en ?d ?l)
      (caja-en ?c ?l)
      (dron-sin-caja ?d)
      (caja-libre ?c)
    )
    :effect (and
      (tiene-caja ?d ?c)
      (not (dron-sin-caja ?d))
      (not (caja-libre ?c))
    )
  )


  (:action meter
    :parameters (
      ?d - dron 
      ?c - caja 
      ?k - contenedor
      ?n1 ?n2 - num
    )
    :precondition (and 
      (tiene-contenedor ?d ?k)
      (tiene-caja ?d ?c) 
      (siguiente ?n1 ?n2)
      (cajas-en-contenedor ?k ?n1)
    )
    :effect (and
      (en-contenedor ?k ?c) 
      (not (tiene-caja ?d ?c))
      (dron-sin-caja ?d) 
      (not (cajas-en-contenedor ?k ?n1))
      (cajas-en-contenedor ?k ?n2)
    )
  )
  
  (:action sacar
    :parameters (
      ?d - dron 
      ?c - caja 
      ?k - contenedor
      ?n1 ?n2 - num
    )
    :precondition (and
      (tiene-contenedor ?d ?k)
      (en-contenedor ?k ?c)
      (dron-sin-caja ?d)
    )
    :effect (and
      (not (en-contenedor ?k ?c)) 
      (not (cajas-en-contenedor ?k ?n2))
      (cajas-en-contenedor ?k ?n1)
      (not (dron-sin-caja ?d))
      (tiene-caja ?d ?c)
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
      (dron-sin-caja ?d)
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
      ?p - persona 
      ?l - localizacion 
      ?t - contenido
      ?n1 ?n2 - num
    )
    :precondition (and
      (dron-en ?d ?l) 
      (tiene-caja ?d ?c)
      
      (persona-en ?p ?l)              
      (contiene ?c ?t)
      (necesita ?p ?t)
      
    )
    :effect (and
      (tiene ?p ?t)
      (not (necesita ?p ?t))
      (not (contiene ?c ?t))
      (not (tiene-caja ?d ?c))
      (dron-sin-caja ?d)
    )
  )
)
