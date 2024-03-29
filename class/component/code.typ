//! target: ../.memo.local/memo.typ

// code 記述における便利関数

#let normal_raw_block(body) = {
  block(
    width: 100%,
    fill: luma(95%),
    inset: (x: 4pt, top: 6pt, bottom: 6pt),
    radius: 2pt,
    body
  )
}

#let console_block(body) = {
  block(
    width: 100%,
    stroke: (left:3pt + luma(30%), rest: 1pt + luma(30%)),
    fill: luma(85%),
    inset: (x: 4pt, top: 6pt, bottom: 6pt),
    radius: 0pt,
    body
  )
}

#let termlog(input, output) = {
  grid(rows: 2, input, block(
    stroke: (left: 3pt + luma(30%)),
    inset: (left: 4pt, top: 4pt),
    output
  ))
}

#let filecode(fname, href: none, body) = {
  show raw.where(block: true): (it) => {
    grid(
      rows: 2,
      block(
        width: 100%,
        stroke: (bottom: none, rest: 1.5pt),
        fill: luma(20%),
        inset: (top: 4pt, bottom: 6pt, x: 4pt),
        radius: (top: 4pt),
        [
          #text(size: 0.8em, fill: white, font: "Courier", fname)
          #if href != none {
            place(
              right + top,
              text(
                size: 0.7em,
                link(
                  href,
                  text(fill: blue.lighten(70%), underline[ View Full Code]),
                ),
              ),
            )
          }
        ],
      ),
      block(
        width: 100%,
        stroke: (top: none, rest: 1.5pt),
        inset: 2pt,
        radius: (bottom: 4pt),
        it,
      ),
    )
  }
  body
}

