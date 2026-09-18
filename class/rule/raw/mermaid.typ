#import "../create.typ": create-rule
#import "block.typ": block as rule-block

#import "@preview/merman:0.3.0"

#let mermaid = create-rule("raw-block-mermaid", default: body => {
  (rule-block.without)(
    merman.mermaid(body.text, typography: (font: ("IBM Plex Sans JP",)))
  )
})


