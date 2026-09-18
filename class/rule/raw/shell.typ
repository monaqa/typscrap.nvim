#import "../create.typ": create-rule
#import "../../component/code.typ"
#import "block.typ": block as rule-block

#let shell = create-rule("raw-block-shell", default: body => {
  (rule-block.without)(code.console_block(body))
})

