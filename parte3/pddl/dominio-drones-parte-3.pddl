(define (domain dominio-drones-3)
  (:requirements :strips :typing :fluents :durative-actions)

  (:types
    dron persona localizacion caja contenido contenedor)

  (:predicates
    (dron-en ?d - dron ?l - localizacion)
    (caja-en ?c - caja ?l - localizacion)
    (persona-en ?p - persona ?l - localizacion)
    (en-deposito ?l - localizacion)

    (necesita ?p - persona ?t - contenido)
    (tiene ?p - persona ?t - contenido)
    (contiene ?c - caja ?t - contenido)
    (contenedor-libre ?k - contenedor)

    (tiene-contenedor ?d - dron ?k - contenedor)
    (en-contenedor ?k - contenedor ?c - caja)
    (dron-libre ?d - dron)
  )

  (:functions
    (cajas-en-contenedor ?k - contenedor)
    (limite-contenedor)
    (fly-cost ?l1 - localizacion ?l2 - localizacion)
    (combustible ?d - dron)
    (max-combustible)
  )

  ;; acciones contenedor
  (:durative-action coger
    :parameters (
      ?d - dron 
      ?k - contenedor 
      ?l - localizacion
    )
    :duration (= ?duration 1)
    :condition (and
      (at start ( and (dron-libre ?d)
      (contenedor-libre ?k)))
      (over all (and (dron-en ?d ?l)
      (en-deposito ?l)))
    )
    :effect (and (at start ( and
      (not (contenedor-libre ?k))
      (not (dron-libre ?d))))
      (at end (tiene-contenedor ?d ?k))
    )
  )

  (:durative-action dejar
    :parameters (
      ?d - dron 
      ?k - contenedor 
      ?l - localizacion
    )
    :duration (= ?duration 1)
    :condition (and
      (at start ( and (tiene-contenedor ?d ?k)
      (= (cajas-en-contenedor ?k) 0)))
      (over all (and (dron-en ?d ?l)
      (en-deposito ?l)))
    )
    :effect (and
      (at start (not (tiene-contenedor ?d ?k)))
      (at end (and (dron-libre ?d) (contenedor-libre ?k)))
    )
  )

  ;; acciones caja y vuelo
  (:durative-action meter
    :parameters (
      ?d - dron 
      ?c - caja 
      ?l - localizacion
      ?k - contenedor
    )
    :duration (= ?duration 1)
    :condition (and 
      (at start ( and (caja-en ?c ?l) 
      (< (cajas-en-contenedor ?k) limite-contenedor ) ))
      (over all ( and (dron-en ?d ?l) 
      (tiene-contenedor ?d ?k)))
    )
    :effect (and 
      (at start(not (caja-en ?c ?l)))
      (at end(and (en-contenedor ?k ?c) 
      (increase (cajas-en-contenedor ?k) 1)))
    )
  )


  (:durative-action volar
    :parameters (
      ?d - dron 
      ?from - localizacion 
      ?to - localizacion
    )
    :duration (= ?duration (fly-cost ?from ?to))
    :condition ( at start
      (and (dron-en ?d ?from)
      (>= (combustible ?d) (fly-cost ?from ?to)))
    )
    :effect (and 
      (at start(not (dron-en ?d ?from)))
      (at end ( and (dron-en ?d ?to)(decrease (combustible ?d) (fly-cost ?from ?to))))
    )
  )

  (:durative-action repostar
    :parameters (
      ?d - dron
      ?l - localizacion
    )
    :duration (= ?duration (- (combustible ?d) max-combustible))
    :condition ( and
      (at start(< (combustible ?d) (max-combustible)))
      (over all( and (en-deposito ?l)(dron-en ?d ?l)))
    )
    :effect (at end
      (assign (combustible ?d) (max-combustible))
    )
  )

  (:durative-action entregar
    :parameters (
      ?d - dron 
      ?c - caja 
      ?k - contenedor
      ?p - persona 
      ?l - localizacion 
      ?t - contenido
    )
    :duration (= ?duration 1)
    :condition (and 
      (at start( and (en-contenedor ?k ?c) 
      (necesita ?p ?t)))
      (over all( and(dron-en ?d ?l) 
      (persona-en ?p ?l)              
      (contiene ?c ?t) 
      (necesita ?p ?t)))
    )
    :effect (and
      (at start( and (tiene ?p ?t)
      (not (necesita ?p ?t))))
      (at end( and (not (en-contenedor ?k ?c))
      (decrease (cajas-en-contenedor ?k) 1)))
    )
  )
)
