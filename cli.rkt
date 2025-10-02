#lang racket/base

(require racket/cmdline
         racket/path
         "compiler/main.rkt"
         "server/web.rkt")

(define build-mode 'incremental)
(define output-dir "output")
(define watch? #f)
(define serve? #f)
(define port 8080)

(module+ main
  (command-line
   #:program "shrdlu"
   #:once-each
   [("-o" "--output") dir
                      "Output directory"
                      (set! output-dir dir)]
   [("-w" "--watch") "Watch for changes"
                     (set! watch? #t)]
   [("-s" "--serve") "Start web server"
                     (set! serve? #t)]
   [("-p" "--port") p
                    "Server port"
                    (set! port (string->number p))]
   [("--full") "Full rebuild"
               (set! build-mode 'full)]
   #:args (source-dir)
   
   (cond
     [serve?
      (thread (λ () (build-site source-dir output-dir build-mode)))
      (start-server #:port port #:root output-dir)
      (when watch?
        (watch-and-rebuild source-dir output-dir))]
     [watch?
      (build-site source-dir output-dir build-mode)
      (watch-and-rebuild source-dir output-dir)]
     [else
      (build-site source-dir output-dir build-mode)])))
