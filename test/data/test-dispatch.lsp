(#:define (foo (:: x Integer)) 1)
(#:define (foo (:: x String)) 2)
(p (#:template foo 1) (#:template foo "1"))
