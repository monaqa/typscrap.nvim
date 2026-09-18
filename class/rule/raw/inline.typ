#import "../create.typ": create-rule

#let inline = create-rule("raw-inline", default: it => {
  set text(
    font: (
      "CommitMono-height105",
      "Hack Nerd Font",
      "IBM Plex Sans JP",
    ),
    size: 1.2em,
  )
  highlight(
    extent: 0.8pt,
    radius: 1.5pt,
    fill: luma(90%),
    it,
  )
})
