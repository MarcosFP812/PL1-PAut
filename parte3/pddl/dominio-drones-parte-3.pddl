(define (domain dominio-drones-3)
  (:requirements :strips :typing :durative-actions :fluents :numeric-fluents :action-costs)

  ;; Tipos de objetos
  (:types dron persona localizacion caja contenido contenedor num)

  ;; Predicados
  (:predicates
    ;; Posición y estado de drones, cajas y personas
    (dron-en ?d - dron ?l - localizacion)
    (caja-en ?c - caja ?l - localizacion)
    (contenedor-en ?k - contenedor ?l - localizacion)
    (persona-en ?p - persona ?l - localizacion)
    (en-deposito ?l - localizacion)

    ;; Contenido de cajas y pertenencias
    (tiene ?p - persona ?t - contenido)
    (contiene ?c - caja ?t - contenido)
    (contenedor-libre ?k - contenedor)
    (necesita ?p - persona ?t - contenido)

    ;; Relación dron - contenedor
    (tiene-contenedor ?d - dron ?k - contenedor)
    (en-contenedor ?k - contenedor ?c - caja)
    (dron-libre ?d - dron)
    (tiene-caja ?d - dron ?c - caja)
    (caja-libre ?c - caja)
    (dron-sin-caja ?d - dron)

    ;; Numeración para gestión de cajas
    (siguiente ?n1 - num ?n2 - num)
    (cajas-en-contenedor ?k - contenedor ?n - num)
    (cero ?n - num)
  )

  ;; Funciones
  (:functions
    (fly-cost ?l1 - localizacion ?l2 - localizacion)
    (total-cost)
  )

  ;; Acciones relacionadas con contenedores
  (:durative-action coger
    :parameters (?d - dron ?k - contenedor ?l - localizacion ?n - num)
    :duration (= ?duration 1)
    :condition (and
      (at start (dron-libre ?d))
      (at start (contenedor-libre ?k))
      (at start (contenedor-en ?k ?l))
      (over all (dron-en ?d ?l))
      (over all (en-deposito ?l))
      (over all (cero ?n))
    )
    :effect (and
      (at start (not (contenedor-libre ?k)))
      (at start (not (dron-libre ?d)))
      (at start (cajas-en-contenedor ?k ?n))
      (at end (tiene-contenedor ?d ?k))
      (at end (not (contenedor-en ?k ?l)))
    )
  )

  (:durative-action dejar
    :parameters (?d - dron ?k - contenedor ?l - localizacion ?n - num)
    :duration (= ?duration 1)
    :condition (and
      (at start (tiene-contenedor ?d ?k))
      (at start (cero ?n))
      (at start (cajas-en-contenedor ?k ?n))
      (over all (dron-en ?d ?l))
      (over all (en-deposito ?l))
    )
    :effect (and
      (at start (not (tiene-contenedor ?d ?k)))
      (at end (dron-libre ?d))
      (at end (contenedor-libre ?k))
      (at end (contenedor-en ?k ?l))
    )
  )

  ;; Acciones de cajas y vuelo
  (:durative-action coger-caja
    :parameters (?d - dron ?c - caja ?l - localizacion)
    :duration (= ?duration 1)
    :condition (and
      (at start (caja-en ?c ?l))
      (at start (dron-sin-caja ?d))
      (at start (caja-libre ?c))
      (over all (dron-en ?d ?l))
    )
    :effect (and
      (at start (not (caja-en ?c ?l)))
      (at start (not (caja-libre ?c)))
      (at start (not (dron-sin-caja ?d)))
      (at end (tiene-caja ?d ?c))
    )
  )

  (:durative-action meter
    :parameters (?d - dron ?c - caja ?k - contenedor ?n1 ?n2 - num)
    :duration (= ?duration 1)
    :condition (and
      (at start (tiene-caja ?d ?c))
      (at start (cajas-en-contenedor ?k ?n1))
      (over all (tiene-contenedor ?d ?k))
      (over all (siguiente ?n1 ?n2))
    )
    :effect (and
      (at start (en-contenedor ?k ?c))
      (at start (not (cajas-en-contenedor ?k ?n1)))
      (at end (not (tiene-caja ?d ?c)))
      (at end (dron-sin-caja ?d))
      (at end (cajas-en-contenedor ?k ?n2))
    )
  )

  (:durative-action sacar
    :parameters (?d - dron ?c - caja ?k - contenedor ?n1 ?n2 - num)
    :duration (= ?duration 1)
    :condition (and
      (at start (en-contenedor ?k ?c))
      (at start (dron-sin-caja ?d))
      (at start (cajas-en-contenedor ?k ?n2))

      (over all (tiene-contenedor ?d ?k))
      (over all (siguiente ?n1 ?n2))
    )
    :effect (and
      (at start (not (en-contenedor ?k ?c)))
      (at start (not (cajas-en-contenedor ?k ?n2)))
      (at end (tiene-caja ?d ?c))
      (at end (not (dron-sin-caja ?d)))
      (at end (cajas-en-contenedor ?k ?n1))
    )
  )

  (:durative-action volar
    :parameters (?d - dron ?from - localizacion ?to - localizacion)
    :duration (= ?duration (+ 0.001 (fly-cost ?from ?to)))
    :condition (and
      (at start (dron-en ?d ?from))
      (over all (dron-sin-caja ?d))
    )
    :effect (and
      (at start (not (dron-en ?d ?from)))
      (at end (dron-en ?d ?to))
      (at end (increase (total-cost) (fly-cost ?from ?to)))
    )
  )

  (:durative-action entregar
    :parameters (?d - dron ?c - caja ?p - persona ?l - localizacion ?t - contenido)
    :duration (= ?duration 1)
    :condition (and
      (at start (tiene-caja ?d ?c))
      (at start (necesita ?p ?t))
      (over all (dron-en ?d ?l))
      (over all (persona-en ?p ?l))
      (over all (contiene ?c ?t))
    )
    :effect (and
      (at start (tiene ?p ?t))
      (at start (not (necesita ?p ?t)))
      (at end (not (tiene-caja ?d ?c)))
      (at end (dron-sin-caja ?d))
    )
  )
)
