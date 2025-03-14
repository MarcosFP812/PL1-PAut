(define (domain dominio-drones-parte2)
  (:requirements :strips :typing :action-costs :fluents)
  ;; Quitamos :negative-preconditions para no permitir precondiciones "not(...)".
  ;; :fluents sirve para manejar el (total-cost) y (fly-cost).

  (:types
    dron persona caja contenedor localizacion contenido num
  )

  ;; -----------------------------------------
  ;; PREDICADOS
  ;; -----------------------------------------
  (:predicates
    ;; DRON
    (dron-en ?d - dron ?l - localizacion)
    (dron-libre ?d - dron)
    (dron-sin-caja ?d - dron)

    ;; CONTENEDORES
    (contenedor-en ?k - contenedor ?l - localizacion)
    (contenedor-libre ?k - contenedor)
    (cajas-en-contenedor ?k - contenedor ?n - num)

    ;; CAJAS
    (caja-en ?c - caja ?l - localizacion)
    (caja-libre ?c - caja)
    (contiene ?c - caja ?t - contenido)
    (caja-en-contenedor ?c - caja ?k - contenedor)

    ;; PERSONAS
    (persona-en ?p - persona ?l - localizacion)
    (necesita ?p - persona ?t - contenido)
    (tiene ?p - persona ?t - contenido)

    ;; NÚMEROS discretos para la capacidad
    (cero ?n - num)
    (siguiente ?n1 - num ?n2 - num)
  )

  ;; -----------------------------------------
  ;; FUNCIONES (fluents)
  ;; -----------------------------------------
  (:functions
    (total-cost) ;; Para la métrica
    (fly-cost ?l1 - localizacion ?l2 - localizacion)
  )

  ;; -----------------------------------------
  ;; ACCIONES
  ;; -----------------------------------------

  ;; 1) meter-caja-en-contenedor
  (:action meter-caja-en-contenedor
    :parameters (?d - dron ?c - caja ?k - contenedor ?l - localizacion ?n - num ?n2 - num)
    :precondition (and
      (dron-en ?d ?l)
      (dron-libre ?d)
      (caja-libre ?c)
      (caja-en ?c ?l)
      (contenedor-en ?k ?l)
      (cajas-en-contenedor ?k ?n)
      (siguiente ?n ?n2)
    )
    :effect (and
      ;; Efectos de borrado (no son precondiciones negativas)
      (not (caja-en ?c ?l))
      (not (caja-libre ?c))
      (not (cajas-en-contenedor ?k ?n))
      ;; Efectos de adición
      (caja-en-contenedor ?c ?k)
      (cajas-en-contenedor ?k ?n2)
      (increase (total-cost) 1)
    )
  )

  ;; 2) sacar-caja-del-contenedor
  (:action sacar-caja-del-contenedor
    :parameters (?d - dron ?c - caja ?k - contenedor ?l - localizacion ?n - num ?n2 - num)
    :precondition (and
      (dron-en ?d ?l)
      (dron-libre ?d)
      (caja-en-contenedor ?c ?k)
      (contenedor-en ?k ?l)
      (siguiente ?n2 ?n)
      (cajas-en-contenedor ?k ?n)
    )
    :effect (and
      (not (caja-en-contenedor ?c ?k))
      (not (cajas-en-contenedor ?k ?n))
      (caja-en ?c ?l)
      (caja-libre ?c)
      (cajas-en-contenedor ?k ?n2)
      (increase (total-cost) 1)
    )
  )

  ;; 3) volar-dron (mover dron y contenedor)
  (:action volar-dron
    :parameters (?d - dron ?k - contenedor ?origen - localizacion ?destino - localizacion)
    :precondition (and
      (dron-en ?d ?origen)
      (contenedor-en ?k ?origen)
    )
    :effect (and
      (not (dron-en ?d ?origen))
      (not (contenedor-en ?k ?origen))
      (dron-en ?d ?destino)
      (contenedor-en ?k ?destino)
      (increase (total-cost) (fly-cost ?origen ?destino))
    )
  )

  ;; 4) entregar-caja
  (:action entregar-caja
    :parameters (?d - dron ?c - caja ?p - persona ?l - localizacion ?t - contenido)
    :precondition (and
      (dron-en ?d ?l)
      (caja-en ?c ?l)
      (caja-libre ?c)
      (persona-en ?p ?l)
      (contiene ?c ?t)
      (necesita ?p ?t)
    )
    :effect (and
      (tiene ?p ?t)
      (not (necesita ?p ?t))
      (increase (total-cost) 1)
    )
  )

  ;; -----------------------------------------
  ;; MÉTRICA
  ;; -----------------------------------------
  (:metric minimize (total-cost))
)
