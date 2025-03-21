#import "component/code.typ"
#import "component/href.typ"
#import "states.typ"
#import "colors.typ"

#import "@preview/showybox:2.0.4": showybox

#let todos(body) = (
  context {
    let spacing = par.spacing
    let checkbox(done: false) = (
      context {
        let clr = text.fill
        set align(center)
        box(
          stroke: 0.5pt + if done {
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

#let meta(slug: none) = {
  let _c = states.slug.update(slug)
  _c + metadata((slug: slug))
}

// 他の scrap へのリンクを作成する。
#let scrap(slug, href: true) = {
  let body = box(
    fill: blue.lighten(90%),
    inset: (x: 4pt, bottom: 1pt),
    outset: (top: 4pt, bottom: 3pt),
    radius: 2pt,
    text(
      fill: blue.darken(50%),
      size: 0.75em,
      weight: 600,
      font: "CommitMono-height105",
      slug,
    ),
  )

  let root = sys.inputs.at("typscrap_root", default: none)
  if href and root != none {
    link("file://" + root + slug + "/preview.pdf", body)
  } else {
    body
  }
}

#let hide(body) = [\*\*\*\*]

#let statement = showybox.with(
  frame: (
    border-color: luma(25%),
    title-color: luma(80%),
    body-color: luma(95%),
  ),
  title-style: (color: luma(20%), weight: 600, align: center),
)

// table まわりの関数たち。

#let th(
  textf: text.with(weight: 600, fill: colors.bg.w0),
  ..args,
) = {
  arguments(
    table.header(
      ..args.pos().map(it => table.cell(
        textf(it),
        fill: colors.fg.w4,
        inset: (y: 0.5em),
        ..args.named(),
      )),
    ),
  )
  arguments(columns: args.pos().len())
}

#let tr(
  headerf: text.with(weight: 600, fill: colors.fg.w4),
  textf: it => it,
  header-cell-args: (align: right),
  col-header: (),
  ..args
) = {
  if col-header == true {
    col-header = (0,)
  }
  if col-header == false {
    col-header = ()
  }
  arguments(..args.pos().enumerate().map(((idx, it)) => table.cell(
    ..{
      if idx in col-header {
        arguments(..header-cell-args)
        arguments(headerf(it))
      } else {
        arguments(..args.named())
        arguments(textf(it))
      }
    }
  )))
}
