#let document(body) = (
  context {
    if target() == "html" {
      html.elem(
        "style",
        attrs: (type: "text/css"),
        read("./github.css"),
      )

      html.elem(
        "script",
        attrs: (src: "https://unpkg.com/mermaid/dist/mermaid.min.js"),
      )
      html.elem("script", "mermaid.initialize({startOnLoad: true});")
      show raw.where(block: true, lang: "mermaid"): it => html.elem(
        "div",
        attrs: (class: "mermaid"),
        it.text,
      )

      set quote(block: true)
      show math.equation.where(block: false): it => {
        html.elem("span", attrs: (role: "math"), html.frame(it))
      }
      show math.equation.where(block: true): it => {
        html.elem("figure", attrs: (role: "math"), html.frame(it))
      }

      body
    } else {
      body
    }
  }
)
