#lang info

(define version "0.1")
(define pkg-authors '(m-hugi))
(define pkg-desc "Library for a handful of NASA's Open APIs")

(define collection "nasa-open-api")
(define deps '("base"))
(define build-deps '("racket-doc" "scribble-lib"))
(define scribblings '(("scribblings/nasa-open-api.scrbl" ())))

