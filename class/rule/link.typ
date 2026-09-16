#import "../component/link-card.typ"
#import "create.typ": create-rule

#let link = create-rule("link", default: link-card.pretty_link.with(
  link_converters: link-card.default_link_converters,
))
