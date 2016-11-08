module MarkdownHtsx

using ...Lists

render(md::Base.Markdown.MD)::List = flatten(render(x) for x in md.content)
render(md::Base.Markdown.Paragraph)::List =
    List(:p, (render(x) for x in md.content)...)
render(md::Base.Markdown.Link)::List =
    List(:a, List(List(:href, md.url)), (render(x) for x in md.text)...)
render(md::Base.Markdown.LaTeX) = "\$$(md.formula)\$"
render(md::String) = md

end
