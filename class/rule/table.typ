#import "create.typ": create-rule
#import "../theme/colors.typ"

#let table = create-rule("table", default: it => block.with(
  clip: true, radius: 2pt, stroke: 1.2pt + colors.fg.w4
))
