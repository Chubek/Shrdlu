#lang racket

(require parser-tools/lex
	 (prefix-in : parser-tools/lex-sre))

(provide (all-defined-out))

(define-lex-abbrev digit (:/ "0" "9"))
(define-lex-abbrev alpha (:or (:/ "a" "z") (:/ "A" "Z")))
(define-lex-abbrev alphanum (:or alpha digit))

(define-lex-abbrev whitespace
  (:or #\space #\tab #\return))

(define-lex-abbrev newline
  (:or #\newline 
        (:seq #\return #\newline)))

(define-lex-abbrev identifier-start
  (:or alpha 
       (:or "!" "$" "%" "&" "*" "/" ":" "<" "=" 
            ">" "?" "^" "_" "~" "+" "-")))

(define-lex-abbrev identifier-continue
   (:or identifier-start digit "." "@"))

(define-lex-abbrev identifier
   (:seq identifier-start
	 (:* identifier-continue)))

(define-lex-abbrev decimal-integer
  (:seq (:? (:or "+" "-"))
        (:+ digit)))

(define-lex-abbrev decimal-float
  (:seq (:? (:or "+" "-"))
        (:* digit)
        "."
        (:+ digit)
        (:? (:seq (:or "e" "E")
                  (:? (:or "+" "-"))
                  (:+ digit)))))

(define-lex-abbrev number
  (:or decimal-integer decimal-float))

(define-lex-abbrev string-char
  (:or (:~ #\" #\\)  ; Any char except " or \
       (:seq #\\ any-char)))  ; Escape sequence

(define-lex-abbrev string-literal
  (:seq #\"
        (:* string-char)
        #\"))

(define-lex-abbrev keyword
  (:seq "#:"
        identifier))

(define-lex-abbrev line-comment
  (:seq ";"
        (:* (:~ #\newline))
        (:? #\newline)))

(define-lex-abbrev block-comment
  (:seq "#|"
        (:* (:or (:~ #\|)
                 (:seq #\| (:~ #\#))))
        "|#"))
