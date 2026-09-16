#import "create.typ": create-rule

#let heading_box(
  it,
  full: false,
  pad: (:),
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
  std.pad(
    ..pad,
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

#let title = create-rule("title", default: heading_box.with(
  full: true,
  pad: (y: 10pt),
  weight: 200,
  size: 22pt,
))

#let h1 = create-rule("h1", default: heading_box.with(
  full: true,
  pad: (top: 2pt, bottom: 4pt),
  inset_bottom: 5pt,
  strk: 1.5pt + black,
  weight: 600,
  size: 18pt,
))

#let h2 = create-rule("h2", default: heading_box.with(
  full: true,
  pad: (y: 6pt),
  inset_bottom: 5pt,
  strk: 0.8pt + black,
  weight: 300,
  size: 18pt,
))

#let h3 = create-rule("h3", default: heading_box.with(
  pad: (y: 3pt),
  inset_bottom: 5pt,
  // strk: 0.8pt + black,
  weight: 600,
  size: 14pt,
))

#let h4 = create-rule("h4", default: heading_box.with(
  pad: (y: 2pt),
  inset_bottom: 3pt,
  size: 12pt,
  strk: (thickness: 1.4pt),
  weight: 500,
))

#let h5 = create-rule("h5", default: heading_box.with(
  inset_bottom: 4pt,
  weight: 700,
  strk: (thickness: 1.2pt, dash: (2pt, 1pt)),
))

#let h6 = create-rule("h6", default: heading_box.with(
  inset_bottom: 3pt,
  strk: 0.5pt,
  weight: 300,
))
