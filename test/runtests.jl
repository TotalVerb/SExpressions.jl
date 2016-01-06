using SExpressions
using Base.Test

@test sexpr"+ 1 1" == SExprVector([SExprID("+"), 1, 1])
@test sexpr"""
(define (sqr x) (^ x 2))
""" == SExprVector([
    SExprVector([
        SExprID("define"),
        SExprVector([SExprID("sqr"), SExprID("x")]),
        SExprVector([SExprID("^"), SExprID("x"), 2])])])
