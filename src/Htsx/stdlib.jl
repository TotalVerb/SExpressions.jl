module StdLib

import ..MarkdownHtsx.render

rendermd(x) = render(Base.Markdown.parse(x))

include("Tags.jl")

end
