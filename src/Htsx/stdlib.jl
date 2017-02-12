module StdLib

using SExpressions.Lists
import ..MarkdownHtsx.render
using Documenter.Writers.HTMLWriter: mdconvert
using Documenter.Utilities.DOM: Node, TEXT

undomify(d::Node) = if d.name === TEXT
    d.text
else
    list(d.name, map(undomify, d.nodes)...)
end
rendermd(x) = undomify(mdconvert(Base.Markdown.parse(x)))

end
