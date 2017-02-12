module StdLib

using SExpressions.Lists
using Documenter.Writers.HTMLWriter: mdconvert
using Documenter.Utilities.DOM: Node, TEXT

undomify(d::Node) = if d.name === TEXT
    d.text
else
    attributes = convert(list, [list(k, v) for (k, v) in d.attributes])
    undomified = map(undomify, d.nodes)
    if isempty(attributes)
        list(d.name, undomified...)
    else
        list(d.name, attributes, undomified...)
    end
end
rendermd(x) = undomify(mdconvert(Base.Markdown.parse(x)))

end
