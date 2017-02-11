(#:define (foo x) (* x x))
(include "file2.lsp" #:remark)
(p "File 1: " (#:template bar 10))
