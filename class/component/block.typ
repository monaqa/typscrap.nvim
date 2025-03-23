// block に関する便利関数。
// cf.) https://github.com/typst/typst/issues/735#issuecomment-2023701180

#let counter-family(id) = {
  let parent = counter(id)
  let parent-step() = parent.step()
  let get-child() = counter(id + str(parent.get().at(0)))
  return (parent-step, get-child)
}

#let breakable-fancyblock(
  body,
  fill: luma(90%),
  border-color: black,
  border-width: 1pt,
  radius: 3pt,
  inset-x: 5pt,
  inset-y: 8pt,
  deco-height: 5pt,
) = {
  let inner_inset_y = 3pt
  let transparent = white.transparentize(100%)
  context {
    let (parent-step, get-child) = counter-family("breakable-fancyblock")
    parent-step()
    let header-count = get-child()

    let border-above = context {
      if header-count.get() == (0,) {
        block(
          width: 100%,
          height: deco-height,
          fill: fill,
          stroke: (bottom: none, rest: border-color + border-width),
          radius: (top: radius),
        )
      } else {
        block(
          width: 100%,
          height: deco-height,
          fill: gradient.linear(transparent, fill, angle: 90deg),
          stroke: (
            x: border-width + gradient.linear(
              transparent,
              border-color,
              angle: 90deg,
            ),
          ),
        )
      }
      header-count.step()
    }
    let border-below = context {
      if header-count.get() == header-count.final() {
        block(
          width: 100%,
          height: deco-height,
          fill: fill,
          stroke: (top: none, rest: border-color + border-width),
          radius: (bottom: radius),
        )
      } else {
        block(
          width: 100%,
          height: deco-height,
          fill: gradient.linear(transparent, fill, angle: 270deg),
          stroke: (
            x: border-width + gradient.linear(
              transparent,
              border-color,
              angle: 270deg,
            ),
          ),
        )
      }
    }
    grid(
      row-gutter: inset-y - deco-height - inner_inset_y,
      grid.header(border-above, repeat: true),
      grid.cell(
        inset: (x: inset-x, y: inner_inset_y),
        stroke: (x: border-color + border-width),
        fill: fill,
        body,
      ),
      grid.footer(border-below, repeat: true),
    )
  }
}
