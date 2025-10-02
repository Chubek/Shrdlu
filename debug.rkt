#lang racket/base

(require syntax/parse/define
         racket/pretty)

(define-simple-macro (debug-expr expr)
  (begin
    (printf "~a:~a: " 
            (syntax-source #'expr)
            (syntax-line #'expr))
    (pretty-write 'expr)
    (printf " => ")
    (define result expr)
    (pretty-write result)
    (newline)
    result))

; Trace document transformations
(define (trace-transform transform doc)
  (printf "=== Transform: ~a ===\n" 
          (object-name transform))
  (printf "Input:\n")
  (pretty-write doc)
  (define result (transform doc))
  (printf "Output:\n")
  (pretty-write result)
  (printf "===================\n")
  result)

; Visual AST inspector
(require mrlib/tree-layout)

(define (visualize-ast ast)
  (define (ast->tree node)
    (match node
      [(list op args ...)
       (tree-layout #:pict (text (symbol->string op))
                   (map ast->tree args))]
      [atom
       (tree-layout #:pict (text (~v atom)))]))
  
  (show-pict (naive-layered (ast->tree ast))))
