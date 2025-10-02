#lang racket

(require parser-tools/lex)

(provide (all-defined-out))

(define-tokens value-tokens 
    (STRING
     NUMBER
     SYMBOL
     IDENTIFIER
     COMMAND
     KEYWORD))

(define-empty-tokens punctuation-tokens
      (LBRACKET
       RBRACKET
       LBRACE
       RBRACE
       LPAREN
       RPAREN
       AT
       SEMICOLON
       EOF))


(struct source-location (line column offset) #:transparent)
(struct positioned-token (token location) #:transparent)

