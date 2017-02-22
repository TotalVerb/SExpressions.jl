# parser for Scheme numbers

import Automa
import Automa.RegExp: @re_str
const RE = Automa.RegExp

# signs
plussign   = re"\+"
minussign  = re"-"
plusminus  = plussign | minussign

# N and Q
natural    = re"[0-9]+"
fraction   = re"/"
rational   = natural * fraction * natural

# R⁺
positive   = natural | rational
# R
real       = RE.opt(plusminus) * positive

# √-1
imagunit   = re"i"
# √-1 R⁺
impositive = positive * imagunit

# C
complex   = real * plusminus * impositive
number    = real | complex

# register actions
natural.actions[:enter]  = [:markn]
natural.actions[:exit]   = [:natural]
plussign.actions[:exit]  = [:positive]
minussign.actions[:exit] = [:negative]
fraction.actions[:exit]  = [:fraction]
imagunit.actions[:exit]  = [:imaginary]

# compile finite-state machine
machine = Automa.compile(number)

# This generates a SVG file to visualize the state machine.
# write("numbers.dot", Automa.dfa2dot(machine.dfa))
# run(`dot -Tpng -o numbers.png numbers.dot`)

# bind action code for each action name
actions = Dict(
    :markn    => :(mark = p),
    :natural  => :(emit(:natural)),
    :negative => :(emit(:negative)),
    :positive => :(emit(:positive)),
    :fraction => :(emit(:fraction)),
    :imaginary => :(emit(:imaginary))
)

# Generate a tokenizing function from the machine.
@eval function tryparse(::Type{Number}, data::String)
    curcomplex = big"0"
    curnat = big"0"
    curreal = big"1"
    cursign = 1
    curnumerator = true
    mark = 0
    $(Automa.generate_init_code(machine))
    p_end = p_eof = endof(data)
    gettoken() = data[mark:p-1]

    nextator!() = begin
        curreal *= curnumerator ? curnat : (1//curnat)
        curnat = big"0"
        curnumerator = false
    end
    nextterm!() = if !iszero(curreal)
        nextator!()
        curcomplex += curreal * cursign
        curreal = big"1"
        cursign = 1
        curnumerator = true
    end
    emit(kind) = if kind == :fraction
        nextator!()
    elseif kind == :positive
        nextterm!()
    elseif kind == :negative
        nextterm!()
        cursign *= -1
    elseif kind == :natural
        curnat = Base.parse(Int, gettoken())
    elseif kind == :imaginary
        cursign *= im
    end
    $(Automa.generate_exec_code(machine, actions=actions))
    nextterm!()
    if cs == 0
        Nullable{Number}(curcomplex)
    else
        Nullable{Number}()
    end
end

