(define (domain dominio-drones-parte2)
  (:requirements :strips :typing :negative-preconditions :action-costs)
  (:types
    dron localizacion caja contenido persona contenedor num
  )

  ;;----------------------------------------------------
  ;; 1. PREDICADOS Y FUNCIONES
  ;;----------------------------------------------------
  (:predicates
    ;; Numeración para representar capacidad y contadores
    (cero ?n - num)
    (siguiente ?n1 - num ?n2 - num)

    ;; Relación de contenido en una caja
    (contiene ?c - caja ?x - contenido)

    ;; Lo que necesita / tiene una persona
    (necesita ?p - persona ?x - contenido)
    (tiene ?p - persona ?x - contenido)

    ;; Ubicaciones de personas, cajas, dron
    (persona-en ?p - persona ?loc - localizacion)
    (caja-en ?c - caja ?loc - localizacion)
    (dron-en ?d - dron ?loc - localizacion)

    ;; Estado de la caja y dron
    (caja-libre ?c - caja)       ; caja no está cogida por el dron
    (dron-libre ?d - dron)       ; dron no está usando manos para caja
    (dron-sin-caja ?d - dron)    ; dron no lleva directamente una caja

    ;; Para el contenedor
    (contenedor-libre ?k - contenedor) ; contenedor vacío o no atado a nada (opcional)
    (cajas-en-contenedor ?k - contenedor ?n - num) ; cuántas cajas hay en el contenedor
    (contenedor-en ?k - contenedor ?loc - localizacion) ; ubicación del contenedor
  )

  ;; Funciones de coste
  (:functions
    (fly-cost ?origen - localizacion ?dest - localizacion)
    (total-cost)
  )

  ;;----------------------------------------------------
  ;; 2. ACCIONES
  ;;----------------------------------------------------

  ;;----------------- A) COGER CAJA (del suelo) -----------------
  (:action coger-caja
   :parameters (?d - dron ?c - caja ?loc - localizacion)
   :precondition (and
       (dron-en ?d ?loc)
       (caja-en ?c ?loc)
       (dron-libre ?d)
       (caja-libre ?c)
       (dron-sin-caja ?d)
     )
   :effect (and
       (not (caja-libre ?c))
       (not (dron-sin-caja ?d))
       (increase (total-cost) 1)
     )
  )

  ;;----------------- B) DEJAR CAJA (en el suelo) -----------------
  (:action dejar-caja
   :parameters (?d - dron ?c - caja ?loc - localizacion)
   :precondition (and
       (dron-en ?d ?loc)
       (not (caja-libre ?c))   ; la caja está en manos del dron
       (not (dron-sin-caja ?d)) 
     )
   :effect (and
       (caja-libre ?c)
       (dron-sin-caja ?d)
       (increase (total-cost) 1)
     )
  )

  ;;----------------- C) METER CAJA EN CONTENEDOR -----------------
  ;; El dron debe tener la caja y el contenedor aún no lleno (usamos 'siguiente ?n ?n2')
  (:action meter-caja-en-contenedor
   :parameters (?d - dron ?c - caja ?k - contenedor ?n ?n2 - num ?loc - localizacion)
   :precondition (and
       (dron-en ?d ?loc)
       (contenedor-en ?k ?loc)
       (not (caja-libre ?c)) 
       (not (dron-sin-caja ?d)) 
       (cajas-en-contenedor ?k ?n)
       (siguiente ?n ?n2)      ; podemos pasar de n a n2
     )
   :effect (and
       ;; Se deja de llevar la caja en el dron
       (not (caja-libre ?c))
       (not (dron-sin-caja ?d))
       ;; Caja ya no está en el suelo
       (decreaseContenedor ?k ?n ?n2) ; Equivale a: (not(cajas-en-contenedor ?k ?n))(cajas-en-contenedor ?k ?n2)
       ;; Como la acción requiere primero “dejar la caja en el contenedor”:
       (caja-libre ?c)  ; interpretamos que la caja queda “libre” dentro del contenedor
       (dron-sin-caja ?d)
       (increase (total-cost) 1)
     )
  )

  ;; Para simplificar la escritura en :effect:
  ;; Se acostumbra expandirlo directamente, así:
  ;; (not (cajas-en-contenedor ?k ?n))
  ;; (cajas-en-contenedor ?k ?n2)

  ;;----------------- D) SACAR CAJA DEL CONTENEDOR -----------------
  (:action sacar-caja-de-contenedor
   :parameters (?d - dron ?c - caja ?k - contenedor ?n ?n2 - num ?loc - localizacion)
   :precondition (and
       (dron-en ?d ?loc)
       (contenedor-en ?k ?loc)
       (dron-libre ?d)
       (dron-sin-caja ?d)
       (cajas-en-contenedor ?k ?n)
       (siguiente ?n2 ?n)  ; para “bajar” de n a n-1 comprobando la relación inversa
       ;; no exigimos que la caja-libre ?c sea FALSE porque la caja está “dentro” del contenedor
     )
   :effect (and
       (not (cajas-en-contenedor ?k ?n))
       (cajas-en-contenedor ?k ?n2)
       (not (dron-sin-caja ?d))
       (not (dron-libre ?d))
       (not (caja-libre ?c)) ; la toma el dron
       (increase (total-cost) 1)
     )
  )

  ;;----------------- E) ENTREGAR CAJA A PERSONA -----------------
  ;; Una vez el dron saca la caja del contenedor, puede entregarla a la persona en la misma localización.
  (:action entregar-caja
   :parameters (?d - dron ?c - caja ?p - persona ?x - contenido ?loc - localizacion)
   :precondition (and
       (dron-en ?d ?loc)
       (persona-en ?p ?loc)
       (contiene ?c ?x)
       (necesita ?p ?x)
       (not (dron-sin-caja ?d)) 
       (not (caja-libre ?c))
     )
   :effect (and
       (tiene ?p ?x)
       (not (necesita ?p ?x))
       ;; dron vuelve a quedar sin la caja
       (dron-sin-caja ?d)
       (caja-libre ?c)
       (increase (total-cost) 1)
     )
  )

  ;;----------------- F) VOLAR -----------------
  (:action volar
   :parameters (?d - dron ?from ?to - localizacion)
   :precondition (and
       (dron-en ?d ?from)
       (not (= ?from ?to))
     )
   :effect (and
       (not (dron-en ?d ?from))
       (dron-en ?d ?to)
       ;; Suma de costes: se usa la función fly-cost
       (increase (total-cost) (fly-cost ?from ?to))
     )))