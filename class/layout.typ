#import "component.typ": href, code

#import "layout/telomere.typ"

#let document(
  show_toc: false,
  link_converters: href.default_link_converters,
  show_telomere: true,
  body
) = {
  // text & paragraph
  set text(font: "IBM Plex Sans JP")
  set par(justify: true, leading: 0.85em)

  // inline elements
  show emph: href.emph_link

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
    pad(y: y_pad, block(
      breakable: false,
      width: if full { 100% } else { auto },
      inset: (bottom: inset_bottom),
      stroke: (bottom: strk),
      text(weight: weight, size: size, it),
    ))
  }

  show heading.where(level: 1): (it) => {
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
  show heading.where(level: 4): heading_box.with(y_pad: 3pt, size: 14pt)
  show heading.where(level: 5): heading_box.with(inset_bottom: 4pt, strk: 0.6pt + black, weight: 300)
  show heading.where(level: 6): heading_box.with(weight: 200)

  // list & enum & term
  set list(
    indent: 0.8em,
    marker: place(center, dy: 0.25em)[#circle(radius: 1.5pt, fill: black)],
  )

  // raw
  show raw: set text(font: (
    "CommitMono-height105",
    "Hack Nerd Font",
    "IBM Plex Mono",
    "Noto Sans Mono CJK JP",
  ))
  show raw.where(block: true): set par(leading: 0.6em)
  show raw.where(block: true): (it) => {
    if it.lang == "sh" {
      code.console_block(it)
    } else {
      code.normal_raw_block(it)
    }
  }

  // page
  set page(
    header: locate(loc => {
      // text(8pt, title)
      if show_telomere {
        telomere.telomere(loc)
      }
    }),
    footer: locate((loc) => {
      let align_dir = left
      if calc.odd(counter(page).at(loc).at(0)) {
        align_dir = right
      }
      set align(align_dir)
      set text(8pt)
      counter(page).display("1")
    }),
  )

  set quote(block: true)
  show quote.where(block: true): set block(stroke: (left: 2pt + gray), inset: 0pt, outset: 5pt)
  show quote.where(block: true): set pad(x: 10pt)

  if show_toc {
    outline(indent: 1em)
    pagebreak()
  }

  body

  [#metadata((date: none)) <meta-tick>]
}
