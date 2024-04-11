#import "component/code.typ"
#import "component/href.typ"

#let todos(body) = {
  let checkbox(done: false) = context {
    let clr = text.fill
    set align(center)
    box(
      stroke: 0.5pt + if done { gray } else { clr },
      width: 0.7em,
      height: 0.7em,
      if done {
        text(baseline: -0.1em, sym.checkmark)
      } else { none },
    )
  }

  show list.item: (it) => {
    let children = it.body.fields().at("children", default: ())
    let first = children.at(0, default: none)
    if first == [~] {
      children.remove(0)
      return list(marker: checkbox(done: true), text(fill: luma(50%), children.join()))
    }
    it
  }

  set list(marker: checkbox(), indent: 1em)

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
