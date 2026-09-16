#import "create.typ": create-rule

#let quote = create-rule("quote", default: block.with(
  spacing: 1.2em,
  stroke: (left: 2pt + gray),
  outset: (left: -4pt, y: 5pt),
  above: 1.2em,
  below: 1.5em,
  width: 100%,
))
