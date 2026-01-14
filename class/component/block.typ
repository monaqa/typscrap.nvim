// block や box に関する便利関数。
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
          fill: if fill == none {none} else {gradient.linear(transparent, fill, angle: 90deg)},
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
          fill: if fill == none {none} else {gradient.linear(transparent, fill, angle: 90deg)},
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

#let labeled-text(
  label: none,
  stroke: 1pt + black,
  fill: none,
  bottom-edge: -0.3em,
  top-edge: 1.0em,
  inset-x: 2pt,
  radius: 2pt,
  body,
) = {
  let stroke = if type(stroke) == color {
    1pt + stroke
  } else if type(stroke) == length {
    stroke + black
  } else {
    stroke
  }

  let _left_tip = if label != none {
    box(
      stroke: (right: none, rest: stroke),
      radius: (left: radius),
      outset: (bottom: - bottom-edge, right: 0.1pt), // わずかに重ねる
      inset: (x: inset-x),
      fill: stroke.paint,
      [#box(height: top-edge)#label]
    )
    // highlight の inset の代わり
    box(
      stroke: (y: stroke),
      outset: (bottom: - bottom-edge),
      fill: fill,
      [#box(height: top-edge, width: inset-x)]
    )
  } else {
    box(
      stroke: (right: none, rest: stroke),
      radius: (left: radius),
      outset: (bottom: - bottom-edge, right: 0.1pt), // わずかに重ねる
      inset: (left: inset-x),
      fill: fill,
      [#box(height: top-edge)]
    )
  }

  let _body = highlight(
    stroke: (y: stroke),
    bottom-edge: bottom-edge,
    top-edge: top-edge,
    fill: fill,
    body,
  )

  let _right = box(
    stroke: (left: none, rest: stroke),
    radius: (right: radius),
    outset: (bottom: - bottom-edge, left: 0.1pt), // わずかに重ねる
    height: top-edge,
    width: inset-x,
    fill: fill,
  )

  _left_tip
  _body
  _right
}
