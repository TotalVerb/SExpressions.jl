module R5RS

# set!
# http://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-7.html?q=set!#%25_idx_104
macro set!(lhs, rhs)
    :($(esc(lhs)) = $(esc(rhs)))
end

export @set!

# not
# http://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-9.html#%_sec_6.3.1
not(x::Bool) = !x
not(::Any) = false

export not

# boolean?
# http://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-9.html#%_sec_6.3.1
isboolean(x::Bool) = true
isboolean(::Any) = false

export isboolean

end
