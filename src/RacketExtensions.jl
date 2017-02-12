# racket extensions
module RacketExtensions

# when, unless
# http://docs.racket-lang.org/reference/when_unless.html
macro when(cond, body...)
    :(if $(esc(cond)); $(map(esc, body)...); end)
end
macro unless(cond, body...)
    :(if !$(esc(cond)); $(map(esc, body)...); end)
end

export @when, @unless

# void
# http://docs.racket-lang.org/guide/void_undefined.html
void(xs...) = nothing

export void

end
