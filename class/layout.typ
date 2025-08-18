#import "component.typ": href, code, scrap, colors
#import "states.typ"

#import "layout/telomere.typ"

#let state_todo = state("todo")

#let document(
  show_toc: false,
  link_converters: href.default_link_converters,
  show_telomere: true,
  confidential: [Internal User Only],
  body,
) = {
  // text & paragraph
  set text(font: "IBM Plex Sans JP", size: 10.5pt)
  set par(justify: true, leading: 0.85em)

  // inline elements
  show emph: set text(
    font: ("Noto Serif", "IBM Plex Sans JP Medm"),
    fill: colors.fg.r1,
  )

  show link: href.pretty_link.with(link_converters: link_converters)

  // heading
  let heading_box(
    it,
    full: false,
    y_pad: 0pt,
    inset_bottom: 0pt,
    strk: none,
    weight: 600,
    size: 1em,
  ) = {
    let font_name = if weight == 500 {
      "IBM Plex Sans JP Medm"
    } else if weight == 600 {
      "IBM Plex Sans JP Smbld"
    } else if weight == 450 {
      "IBM Plex Sans JP Text"
    } else {
      "IBM Plex Sans JP"
    }
    pad(
      y: y_pad,
      {
        block(
          breakable: false,
          inset: (bottom: inset_bottom),
          stroke: (
            bottom: if full {
              none
            } else {
              strk
            },
          ),
          text(weight: weight, size: size, font: font_name, it),
        )
        if full and strk != none {
          place(bottom, line(length: 100%, stroke: strk))
        }
      },
    )
  }

  show heading.where(level: 1): it => {
    [#metadata((date: none)) <meta-tick>]
    pagebreak(weak: true)
    heading_box(it, full: true, y_pad: 16pt, weight: 200, size: 22pt)
  }
  show heading.where(level: 2): heading_box.with(
    full: true,
    y_pad: 3pt,
    inset_bottom: 5pt,
    strk: 0.8pt + black,
    weight: 300,
    size: 18pt,
  )
  show heading.where(level: 3): heading_box.with(
    y_pad: 3pt,
    inset_bottom: 5pt,
    strk: 1.5pt + black,
    size: 14pt,
  )
  show heading.where(level: 4): heading_box.with(
    y_pad: 2pt,
    inset_bottom: 3pt,
    size: 12pt,
    strk: (thickness: 1.2pt, dash: (2pt, 1pt)),
    weight: 500,
  )
  show heading.where(level: 5): heading_box.with(inset_bottom: 4pt, weight: 700)
  show heading.where(level: 6): heading_box.with(
    inset_bottom: 3pt,
    strk: 0.5pt,
    weight: 300,
  )

  set outline(depth: 3, indent: 1em, title: [目次])
  show outline: it => {
    show heading.where(level: 1): _ => heading_box(y_pad: 5pt)[目次]
    it
  }

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

  // list & enum & term
  set list(
    indent: 0.8em,
    // marker: place(center, dy: 0.25em)[#circle(radius: 1.5pt, fill: black)],
    marker: depth => (
      context {
        let default = place(center, dy: 0.25em)[#circle(radius: 1.5pt, fill: black)]
        let v = state_todo.get()
        if v == none {
          return default
        }
        let status = v.at("status")
        let due = v.at("due")
        if status == none {
          default
        }else if status == "done" {
          checkbox(done: true)
        } else {
          checkbox(done: false)
        }
      }
    )
  )

  show list.item: it => {
    let children = it.body.at("children", default: ())
    let md = children.filter(c => c.func() == metadata).fold(
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
    state_todo.update(md)
    v(0pt) // 複数の update がくっつくと意図しない挙動を引き起こすため、あえてつける
    if md.due != none {
      place(
        right,
        box(
          fill: colors.fg.r0,
          inset: 3pt,
          radius: 2pt,
          text(fill: colors.bg.w0, size: 0.8em, weight: 600, [Due: #md.due])
        ),
      )
    }
    it
    state_todo.update(none)
  }

  show list: set block(width: 100%)

  // raw
  show raw: set text(font: (
    "CommitMono-height105",
    "Hack Nerd Font",
    "IBM Plex Sans JP",
  ))
  // たぶんデフォルトで 0.8em みたいな何かがかかってるので、1.2 倍して 0.96em っぽくしとく
  show raw.where(block: false): set text(size: 1.2em)
  show raw.where(block: false): it => box(
    outset: (x: 0.8pt, y: 3pt),
    radius: 1.5pt,
    fill: luma(90%),
    it,
  )
  show raw.where(block: true): set par(leading: 0.6em, justify: false)
  show raw.where(block: true): it => {
    if it.lang == "sh" {
      code.console_block(it)
    } else if it.lang == "ish" {
      code.interactive_block(it)
    } else {
      code.normal_raw_block(it)
    }
  }

  // table
  set table(
    fill: (_, y) => {
      if calc.even(y) {
        colors.bg.w1
      } else {
        colors.bg.w0
      }
    },
    stroke: none,
    // Tips: https://github.com/typst/typst/discussions/3692
    // stroke: (x, y) => (
    //   left: if x == 0 {1pt} else {0pt},
    //   top: if y == 0 {1pt} else {0pt},
    //   right: 1pt,
    //   bottom: 1pt,
    // )
  )
  show table: block.with(clip: true, radius: 2pt, stroke: 1pt + colors.fg.w4)

  // page
  set page(
    margin: (x: 1.5cm, y: 2.5cm),
    header: context {
      let slug = states.slug.final()
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
  show quote.where(block: true): set block(spacing: 1.2em)
  show quote.where(block: true): block.with(
    stroke: (left: 2pt + gray),
    outset: (left: -4pt, y: 5pt),
    above: 1.2em,
    below: 1.5em,
  )

  if show_toc {
    outline(indent: 1em)
    pagebreak()
  }

  body

  [#metadata((date: none)) <meta-tick>]
}
