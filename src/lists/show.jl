#=
 HOW TO SHOW AN S-EXPRESSION
 ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡

  • cap lines to 80 characters (if possible)
  • overflow all s-expressions if not
  • if head is short [≤ 3], then keep first argument on the same line

 performance isn’t a concern but if it’s too shitty we can consider ropes
=#

immutable ShowListContext
    indent::Int
    limit::Int
end

# arbitrarily decide that there’s always room for 5 more
space(ctx::ShowListContext) = max(5, ctx.limit - ctx.indent)

# performance is really not our concern
sindent(ctx::ShowListContext) = " " ^ ctx.indent

# “if we append or prepend, we should indent, not indented”
# no. indent is also a noun. indented makes it clear what this does
indented(ctx::ShowListContext, i=2) = ShowListContext(ctx.indent + i, ctx.limit)

# putting an ‘s’ in front of all functions that return strings is terrible style
# but sometimes terrible style is the best we’ve got
sprintwidth(α) = sum(charwidth(c) for c in unparse(α))

spprintall(ctx::ShowListContext, α) = join((β -> spprint(ctx, β)) ∘ α, '\n')

spprint(ctx::ShowListContext, α) = sindent(ctx) * unparse(α)

function spprint(ctx::ShowListContext, α::Cons)
    if sprintwidth(α) ≤ space(ctx) || length(α) ≤ 1
        # verbatim
        sindent(ctx) * unparse(α)
    elseif (spw = sprintwidth(car(α))) ≤ 3 && length(α) ≥ 3
        # (car cadr ¶ ...) format
        ctxi = indented(ctx, spw + 2)
        sindent(ctx) * "(" * unparse(car(α)) * " " * unparse(cadr(α)) * "\n" *
                spprintall(ctxi, cddr(α)) * ")"
    else
        # (car ¶ ...) format
        ctxi = indented(ctx, 2)
        sindent(ctx) * "(" * unparse(car(α)) * "\n" *
                spprintall(ctxi, cdr(α)) * ")"
    end
end

spprint(α::List) = spprint(ShowListContext(0, 80), α)

function Base.show(io::IO, α::List)
    if get(io, :multiline, false)
        print(io, spprint(α))
    else
        print(unparse(α))
    end
end
