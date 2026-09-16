#let TODO = metadata((status: "todo"))
#let DOING = metadata((status: "doing"))
#let DONE = metadata((status: "done"))
#let todo(due: none) = metadata((due: due))

#let checkbox(done: false) = (
  context {
    let clr = text.fill
    set align(center)
    box(
      stroke: 0.5pt
        + if done {
          gray
        } else {
          clr
        },
      width: 0.7em,
      height: 0.7em,
      if done {
        text(baseline: -0.1em, sym.checkmark)
      } else {
        none
      },
    )
  }
)

#let todos(body) = (
  context {
    let spacing = par.spacing
    set list(marker: checkbox(), indent: 1em, spacing: spacing)

    show list.item: it => {
      let children = it.body.fields().at("children", default: ())
      let first = children.at(0, default: none)
      if first == [~] {
        children.remove(0)
        return list(
          marker: checkbox(done: true),
          text(fill: luma(50%), children.join()),
        )
      }
      it
    }

    body
  }
)
