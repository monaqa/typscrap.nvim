#import "component/code.typ"
#import "component/href.typ"

#let todos(body) = {
  let checkbox(done: false) = {
    set align(center)
    box(
      stroke: 0.5pt + if done {gray} else {black},
      width: 0.7em,
      height: 0.7em,
      if done {
        text(baseline: -0.1em, sym.checkmark)
      } else {none}
    )
  }

  set list(marker: checkbox(), indent: 1em)
  set enum(numbering: (num) => checkbox(done: true), indent: 1em)
  show enum: set text(fill: gray)

  body
}

#let tick(date) = {
  if type(date) == "string" {
    let (year, month, day) = date.split("-")
    date = datetime(year: int(year), month: int(month), day: int(day))
  }
  [#metadata((date: date)) <meta-tick>]
}

#let alias(..slugs) = [
  #metadata((slugs: slugs.pos())) <meta-alias>
]

#let meta(slug: none) = metadata((slug: slug))
