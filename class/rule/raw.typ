#import "create.typ": create-rule
#import "../component/code.typ": console_block, normal_raw_block

#import "@preview/merman:0.3.0": mermaid

#let raw-inline = create-rule("raw-inline", default: it => {
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

#let raw-block = create-rule("raw-block")

#let termlog(input, output) = {
  grid(
    rows: 2,
    (raw-block.apply-within)(console_block.with(radius: 0pt), input),
    block(
      stroke: (left: 3pt + luma(30%)),
      inset: (left: 4pt, y: 4pt),
      fill: luma(98%),
      width: 100%,
      (raw-block.without)(output),
    ),
  )
}

#let interactive_block(body) = {
  let state = "cmd"
  let cmds = ()
  let results = ()
  for line in body.text.split("\n") {
    if state == "cmd" {
      if line.starts-with("❯ ") {
        cmds.push(line.slice(4))
      } else {
        state = "out"
        results.push(line)
      }
    } else if state == "out" {
      if line.starts-with("❯ ") {
        termlog[
          #raw(lang: "sh", block: true, cmds.join("\n"))
        ][
          #raw(block: true, results.join("\n"))
        ]
        cmds = ()
        results = ()
        cmds.push(line.slice(4))
        state = "cmd"
      } else {
        results.push(line)
      }
    }
  }

  if cmds.len() > 0 {
    if results.len() == 0 {
      raw(lang: "sh", block: true, cmds.join("\n"))
    } else {
      termlog[
        #raw(lang: "sh", block: true, cmds.join("\n"))
      ][
        #raw(block: true, results.join("\n"))
      ]
    }
  }
}

#let setup-raw-block() = {
  (rule.raw-block.apply)(it => {
    if it.lang == "mermaid" {
      return mermaid(it.text, typography: (font: ("IBM Plex Sans JP",)))
    }

    if it.lang == "sh" {
      code.console_block(it)
    } else if it.lang == "ish" {
      rule.interactive_block(it)
    } else {
      code.normal_raw_block(it)
    }
  })
}
