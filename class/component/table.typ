#import "../theme/colors.typ"

#let th(..args) = {
  arguments(
    table.header(
      ..args
        .pos()
        .map(it => table.cell(
          text(weight: 600, fill: colors.bg.w0, it),
          fill: colors.fg.w4,
          inset: (y: 0.5em),
          ..args.named(),
        )),
    ),
  )
  arguments(columns: args.pos().len())
}

#let tf(..args) = {
  arguments(
    table.footer(
      ..args
        .pos()
        .map(it => table.cell(
          it,
          stroke: (top: 1pt),
          inset: (y: 0.5em),
          ..args.named(),
        )),
    ),
  )
  arguments(columns: args.pos().len())
}

#let tr(..args) = {
  arguments(
    ..args.pos().map(it => table.cell(it, ..args.named())),
  )
}

#let termtable(
  header: none,
  body,
  ..args,
) = {
  let items = body.at("children", default: ()).filter(c => c.func() == terms.item).map(item => item.fields())

  table(
    ..{
      if header != none {
        th(..header)
      }
      arguments(columns: 2)
      for (term, description) in items {
        tr[#term][#description]
      }
    },
    ..args
  )
}
