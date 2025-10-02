#lang racket

(require parser-tools/lex
	 (prefix-in : parser-tools/lex-sre)
	 "token-types.rkt"
	 "lexer-patterns.rkt")


(provide make-lexer
	 tokenize-string
	 tokenize-file)

(define (make-position-tracker)
  (let ([line 1]
	[column 1]
	[offset 0])
    (λ (action [chars 1])
      (case action
	[(get) (source-location line column offset)]
	[(advance)
	 (set! offset (+ offset chars))
	 (set! column (+ column chars))]
	[(newline)
	 (set! offset (+ offset 1))
	 (set! line (+ line 1))
	 (set! column 1)]))))


(define (make-shrdlu-lexer input-port [source-name "unknown"])
  (define pos-tracker (make-position-tracker))

  (define shrdlu-lexer
    (lexer-src-pos
      [whitespace
	(begin
	  (pos-tracker 'advance (string-length lexeme))
	  (return-without-pos (shrdlu-lexer input-port)))]

      [newline
	(begin
	  (pos-tracker 'newline)
	  (return-without-pos (shrdlu-lexer input-port)))]

      [(:or line-comment block-comment)
       (return-without-pos (shrdlu-lexer input-port))]

      ["@"
       (token-AT)]

      [(:seq "@" identifier)
       (token-COMMAND (substring lexeme 1))]

      ["[" (token-LBRACKET)]
      ["]" (token-RBRACKET)]
      ["{" (token-LBRACE)]
      ["}" (token-RBRACE)]
      ["(" (token-LPAREN)]
      [")" (token-RPAREN)]
      [";" (token-SEMICOLON)]

      [keyword
        (token-KEYWORD (string->keyword (substring lexeme 2)))]

      [number
	(token-NUMBER (string->number lexeme))]

      [identifier
	(token-IDENTIFIER (string->symbol lexeme))]

      [(eof)
       (token-EOF)]

      [any-char
	(raise-lex-error source-name
			 (pos-tracker 'get)
			 (format "Illegal character: ~a" lexeme))]))
  shrdlu-lexer)

(define (process-string-escapes str)
  (define (process-char chars acc)
    (match chars
      ['() (list->string (reverse acc))]
      [(cons #\\ (cons c rest))
       (define escaped-char
         (case c
           [(#\n) #\newline]
           [(#\t) #\tab]
           [(#\r) #\return]
           [(#\") #\"]
           [(#\\) #\\]
           [(#\0) #\null]
           [else c]))  ; Unknown escape, keep as-is
       (process-char rest (cons escaped-char acc))]
      [(cons c rest)
       (process-char rest (cons c acc))]))
  
  (process-char (string->list str) '()))

(define (raise-lex-error source pos message)
  (raise
   (exn:fail:read
    (format "~a:~a:~a: ~a" 
            source 
            (source-location-line pos)
            (source-location-column pos)
            message)
    (current-continuation-marks)
    '())))

(define (tokenize-string str #:source [source "string"])
  (define input (open-input-string str))
  (define lexer (make-shrdlu-lexer input source))
  (define (collect-tokens)
    (define tok (lexer))
    (if (eq? (position-token-token tok) 'EOF)
        '()
        (cons tok (collect-tokens))))
  (collect-tokens))

(define (tokenize-file path)
  (call-with-input-file path
    (λ (input)
      (define lexer (make-shrdlu-lexer input path))
      (define (collect-tokens)
        (define tok (lexer))
        (if (eq? (position-token-token tok) 'EOF)
            '()
            (cons tok (collect-tokens))))
      (collect-tokens))))
