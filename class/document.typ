#import "rule.typ"
#import "theme/colors.typ"
#import "_internal/state.typ"
#import "component/metadata.typ": scrap
#import "component/todo.typ": checkbox

#let document(
  show_toc: false,
  show_telomere: true,
  confidential: [Internal Use Only],
  body,
) = {
  // text & paragraph
  set text(font: "IBM Plex Sans JP", size: 10.5pt)
  set par(justify: true, leading: 0.85em)
  // "？」" などのカーニングがおかしくなる問題の対処
  show regex("[！？]"): box.with(width: 1em)

  // inline elements
  show emph: set text(font: "IBM Plex Sans JP Medm")
  show link: rule.link.show
  show hide: rule.hide.show

  // heading
  show title: rule.title.show
  show heading.where(level: 1): rule.h1.show
  show heading.where(level: 2): rule.h2.show
  show heading.where(level: 3): rule.h3.show
  show heading.where(level: 4): rule.h4.show
  show heading.where(level: 5): rule.h5.show
  show heading.where(level: 6): rule.h6.show

  set outline(depth: 3, indent: 1em, title: [目次])

  // list & enum & term
  set list(
    indent: 0.8em,
    // marker: place(center, dy: 0.25em)[#circle(radius: 1.5pt, fill: black)],
    marker: depth => (
      context {
        let default = place(center, dy: 0.25em)[#circle(radius: 1.5pt, fill: black)]
        let v = state.todo.get()
        if v == none {
          return default
        }
        let status = v.at("status")
        let due = v.at("due")
        if status == none {
          default
        } else if status == "done" {
          checkbox(done: true)
        } else {
          checkbox(done: false)
        }
      }
    ),
  )

  show list.item: it => {
    let children = it.body.at("children", default: ())
    let md = children
      .filter(c => c.func() == metadata)
      .fold(
        (status: none, due: none),
        (acc, data) => {
          let v = data.value
          if "status" in v {
            acc.status = v.status
          }
          if "due" in v {
            acc.due = v.due
          }
          acc
        },
      )
    state.todo.update(md)
    v(0pt) // 複数の update がくっつくと意図しない挙動を引き起こすため、あえてつける
    if md.due != none {
      place(
        right,
        box(
          fill: colors.fg.r0,
          inset: 3pt,
          radius: 2pt,
          text(fill: colors.bg.w0, size: 0.8em, weight: 600, [Due: #md.due]),
        ),
      )
    }
    it
    state.todo.update(none)
  }

  show raw.where(block: false): rule.raw-inline.show
  show raw.where(block: true): rule.raw-block.show
  rule.setup-raw-block()

  // table
  set table(
    fill: (_, y) => {
      if calc.even(y) {
        colors.bg.w1
      } else {
        colors.bg.w0
      }
    },
    // stroke: colors.bg.w3 + 0.8pt,
    // Tips: https://github.com/typst/typst/discussions/3692
    stroke: (x, y) => (
      left: if x == 0 { 0pt } else { colors.bg.w4 + 1.0pt },
      // top: if y == 0 {1pt} else {0pt},
      // right: 1pt,
      // bottom: 1pt,
    ),
  )
  show table: rule.table.show

  // page
  set page(
    margin: (x: 1.5cm, y: 2.5cm),
    header: context {
      let slug = state.slug.final()
      if slug != none {
        place(left + bottom, scrap(slug, href: false))
      }

      if confidential != none {
        let confidential_mark = {
          let color = red.darken(20%)
          box(
            stroke: color + 2pt,
            inset: (x: 3pt, y: 4pt),
            align(center, text(fill: color, size: 9pt)[*#confidential*]),
          )
        }
        place(right + bottom, confidential_mark)
      }
    },
    footer: context {
      let align_dir = left
      if calc.odd(counter(page).get().at(0)) {
        align_dir = right
      }
      set align(align_dir)
      set text(8pt)
      counter(page).display("1")
    },
  )

  set quote(block: true)
  show quote.where(block: true): rule.quote.show

  show math.equation.where(block: false): set math.frac(style: "horizontal")

  if show_toc {
    outline(indent: 1em)
    pagebreak()
  }

  body

  // [#metadata((date: none)) <meta-tick>]
}
