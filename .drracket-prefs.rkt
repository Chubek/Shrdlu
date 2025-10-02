; .drracket-prefs.rkt
#lang racket/base

(define preferences
  '((drracket:tabify-on-return? #f)
    (drracket:indent-mode 'racket)
    (drracket:show-line-numbers? #t)
    (drracket:syntax-coloring-active? #t)
    (drracket:backup-files? #t)))

; Custom keybindings for Shrdlu development
(define keybindings
  '(("c:x;c:t" "run-shrdlu-tests")
    ("c:x;c:b" "build-shrdlu-site")
    ("c:x;c:p" "preview-shrdlu-output")))
