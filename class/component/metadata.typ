#import "../_internal/state.typ"

#let meta(slug: none) = {
  let _c = state.slug.update(slug)
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
