//! target: ../.memo.local/memo.typ
#import "../colors.typ"
#import "block.typ": breakable-fancyblock

// code 記述における便利関数

#let normal_raw_block(body) = {
  breakable-fancyblock(
    fill: colors.bg.w0,
    border-width: 0.5pt,
    border-color: colors.fg.w0,
    inset-x: 4pt,
    inset-y: 6pt,
    deco-height: 4pt,
    radius: 2pt,
    body
  )
}

#let console_block(body) = {
  block(
    width: 100%,
    stroke: (left: 3pt + colors.fg.w0),
    fill: colors.bg.w2,
    inset: (x: 4pt, top: 6pt, bottom: 6pt),
    radius: 2pt,
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

#let _wrap_zerowidth_space(s) = {
  if s.starts-with(regex("\\s")) {
    s = "​" + s
  }
  if s.ends-with(regex("\\s")) {
    s = s + "​"
  }
  s
}

#let default_highlight_rule(state, s) = {
  if state.at("", default: false) {
    return box(
      text(_wrap_zerowidth_space(s), fill: white),
      fill: black,
      outset: (y: 2pt),
    )
  }
  if state.at("=", default: false) {
    return box(
      text(_wrap_zerowidth_space(s)),
      fill: black.lighten(70%),
      outset: (y: 2pt),
    )
  }
  return s
}

// ハイライト適用可能なコードブロック。
#let with_hl(
  state_chars: ("", "="),
  hl_func: default_highlight_rule,
  wrapper: normal_raw_block,
  content,
) = {
  let special_pattern = regex("\[(.*?)\[|\](.*?)\]|\\n")

  set par(first-line-indent: 0pt)
  show raw: (raw_block) => {
    let _text = raw_block.text
    let d = _text.matches(special_pattern)

    let idx = 0
    let state = (:)
    let _content = []
    for item in d {
      _content = _content + hl_func(state, _text.slice(idx, item.start))

      // state 更新 or 特殊でない文字として扱う
      if item.text == "\n" {
        _content = _content + linebreak()
      } else {
        let (s, e) = item.captures
        if not (s in state_chars or e in state_chars) {
          _content = _content + item.text
        } else {
          if e == none {
            state.insert(s, true)
          } else {
            state.insert(e, false)
          }
        }
      }

      idx = item.end
    }
    _content = _content + hl_func(state, _text.slice(idx))

    wrapper(_content)
  }

  content
}
