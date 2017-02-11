module R5RS

# set!
# http://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-7.html?q=set!#%25_idx_104
macro set!(lhs, rhs)
    :($(esc(lhs)) = $(esc(rhs)))
end

export @set!

end
