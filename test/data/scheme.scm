(define (sqr x)
  (* x x))

(define (map f lst)
  (if (null? lst)
      lst
      (cons (car lst) (map f (cdr lst)))))
