#lang info

(define collection "shrdlu")
(define version "0.1.0")

(define deps 
  '("base"
    "parser-tools-lib"
    "web-server-lib"
    "draw-lib"
    "pict-lib"
    "rackunit-lib"))

(define build-deps 
  '("scribble-lib"
    "racket-doc"))

(define scribblings 
  '(("scribblings/shrdlu.scrbl" (multi-page))))

(define raco-commands
  '(("shrdlu" (submod shrdlu/cli main) "Shrdlu command line tool" #f)))

(define compile-omit-paths '("examples"))
