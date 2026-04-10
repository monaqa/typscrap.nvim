#import "component/code.typ"
#import "component/href.typ"
#import "component/chart.typ"
#import "component/block.typ": breakable-fancyblock, labeled-text
#import "states.typ"
#import "colors.typ"

#import "@preview/showybox:2.0.4": showybox

#let TODO = metadata((status: "todo"))
#let DOING = metadata((status: "doing"))
#let DONE = metadata((status: "done"))
#let todo(due: none) = metadata((due: due))

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

#let th(..args) = {
  arguments(
    table.header(
      ..args.pos().map(it => table.cell(
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
      ..args.pos().map(it => table.cell(
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
  body
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
    }
  )
}

#let chatbot(
  question,
  answer,
  bot-name: [Gemini],
  gutter: 5pt,
  q-width: 75%,
  a-width: 95%,
  q-block-args: arguments(),
  a-block-args: arguments(),
  name-box-args: arguments(),
  name-text-args: arguments(),
) = {
  grid(
    row-gutter: gutter,
    grid(
      columns: (1fr, q-width),
      none,
      block(
        width: 100%,
        fill: colors.bg.b0.lighten(50%),
        stroke: colors.bg.b1 + 1pt,
        inset: 10pt,
        radius: (top-right: 0pt, rest: 12pt),
        ..q-block-args,
        question,
      ),
    ),
    grid(
      columns: (a-width, 1fr),
      stack(
        box(
          inset: 5pt,
          fill: colors.fg.c2,
          stroke: colors.fg.c2 + 1.5pt,
          radius: 2pt,
          ..name-box-args,
          text(
            size: 0.95em,
            weight: 600,
            fill: white,
            ..name-text-args,
            bot-name,
          ),
        ),
        block(
          width: 100%,
          fill: colors.bg.g0.lighten(70%),
          stroke: colors.fg.c2 + 1.5pt,
          inset: 10pt,
          radius: (top-left: 0pt, rest: 12pt),
          ..a-block-args,
          [
            #set heading(offset: 2)
            #answer
          ],
        ),
      ),
      none,
    )
  )
}
