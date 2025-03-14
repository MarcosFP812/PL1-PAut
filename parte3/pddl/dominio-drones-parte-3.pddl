(define (domain dominio-drones-2)
  (:requirements :strips :typing :durative-actions)

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

  ;; acciones contenedor
  (:durative-action coger
    :parameters (
      ?d - dron 
      ?k - contenedor 
      ?l - localizacion
      ?n - num
    )
    :duration (= ?duration 1)
    :condition (and
      (at start ( and (dron-libre ?d)
      (contenedor-libre ?k)))
      (over all (and (dron-en ?d ?l)
      (en-deposito ?l) (cero ?n))
    )
    :effect (and (at start ( and
      (not (contenedor-libre ?k))
      (not (dron-libre ?d))
      (cajas-en-contenedor ?k ?n)))
      (at end (tiene-contenedor ?d ?k))
    )
  )

  (:durative-action dejar
    :parameters (
      ?d - dron 
      ?k - contenedor 
      ?l - localizacion
      ? n - num
    )
    :duration (= ?duration 1)
    :condition (and
      (at start ( and (tiene-contenedor ?d ?k)
      (cero ?n)
      (cajas-en-contenedor ?k ?n)))
      (over all (and (dron-en ?d ?l)
      (en-deposito ?l)))
    )
    :effect (and
      (at start (not (tiene-contenedor ?d ?k)))
      (at end (and (dron-libre ?d) (contenedor-libre ?k)))
    )
  )

  ;; acciones caja y vuelo

  (:durative-action coger-caja
    :parameters (
      ?d - dron 
      ?c - caja 
      ?l - localizacion
    )
    :duration (= ?duration 1)
    :condition (and
      (at start( and (caja-en ?c ?l) (dron-sin-caja ?d) (caja-libre ?c)))
      (over all( dron-en ?d ?l ))
    )
    :effect (and
      (at start( and (not (dron-sin-caja ?d)) (not (caja-libre ?c)) (not (caja-en ?c ?l)) ))
      (at end( and (tiene-caja ?d ?c)  ))
    )
  )

  (:durative-action meter
    :parameters (
      ?d - dron 
      ?c - caja 
      ?k - contenedor
      ?n1 ?n2 - num
    )
    :duration (= ?duration 1)
    :condition (and 
      (at start (and (tiene-caja ?d ?c) (cajas-en-contenedor ?k ?n1) ))
      (over all ( and ( (tiene-contenedor ?d ?k) (siguiente ?n1 ?n2) ))
    )
    :effect (and 
      (at start(and (en-contenedor ?k ?c) (not (cajas-en-contenedor ?k ?n1)) ))
      (at end(and (not (tiene-caja ?d ?c)) (dron-sin-caja ?d) (cajas-en-contenedor ?k ?n2) ))
    )
  )

  (:durative-action sacar
    :parameters (
      ?d - dron 
      ?c - caja 
      ?k - contenedor
      ?n1 ?n2 - num
    )
    :duration (= ?duration 1)
    :condition (and
      (at start (and  (en-contenedor ?k ?c) (dron-sin-caja ?d) (cajas-en-contenedor ?k ?n2) ))
      (over all ( and ( (tiene-contenedor ?d ?k) (siguiente ?n1 ?n2) ))
    )
    :effect (and
      (at start(and  (not (en-contenedor ?k ?c))  (not (cajas-en-contenedor ?k ?n2)) ))
      (at end(and (tiene-caja ?d ?c) (not (dron-sin-caja ?d)) (cajas-en-contenedor ?k ?n1) ))
    )
  )

  (:durative-action volar
    :parameters (
      ?d - dron 
      ?from - localizacion 
      ?to - localizacion
    )
    :duration (= ?duration (fly-cost ?from ?to))
    :condition ( at start(dron-en ?d ?from))
      (over all (dron-sin-caja ?d))
    )
    :effect (and 
      (at start(not (dron-en ?d ?from)))
      (at end ( and (dron-en ?d ?to) (increase total-cost (fly-cost ?from ?to)) ))
    )
  )

  (:durative-action entregar
    :parameters (
      ?d - dron 
      ?c - caja 
      ?p - persona 
      ?l - localizacion 
      ?t - contenido
    )
    :duration (= ?duration 1)
    :condition (and 
      (at start( and (tiene-caja ?d ?c) (necesita ?p ?t)))
      (over all( and(dron-en ?d ?l) 
      (persona-en ?p ?l)              
      (contiene ?c ?t) ))
    )
    :effect (and
      (at start( and (tiene ?p ?t)
      (not (necesita ?p ?t))))
      (at end( and (not (tiene-caja ?d ?c))
      (dron-sin-caja ?d)))
    )
  )
)
