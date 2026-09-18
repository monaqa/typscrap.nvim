#import "../create.typ": create-rule
#import "../../theme/colors.typ"
#import "../../component/code.typ"
#import "block.typ": block as rule-block
#import "shell.typ": shell as rule-shell

#let _termlog(input, output) = {
  grid(
    rows: 2,
    (rule-shell.apply-within)(code.console_block.with(radius: 0pt), input),
    block(
      stroke: (left: 3pt + luma(30%)),
      inset: (left: 4pt, y: 4pt),
      fill: luma(98%),
      width: 100%,
      (rule-block.without)(output),
    ),
  )
}

#let _interactive_block(body) = {
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
        _termlog[
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
      _termlog[
        #raw(lang: "sh", block: true, cmds.join("\n"))
      ][
        #raw(block: true, results.join("\n"))
      ]
    }
  }
}


#let interactive-shell = create-rule("raw-block-interactive-shell", default: body => {
  set text(
    font: (
      "CommitMono-height105",
      "Hack Nerd Font",
      "IBM Plex Sans JP",
    ),
  )
  set par(leading: 0.6em, justify: false)

  (rule-block.without)(_interactive_block(body))
})
