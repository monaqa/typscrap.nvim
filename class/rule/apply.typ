#import "raw/inline.typ": inline

#let raw-inline-breakable(body) = (inline.prepend-within)(it => it.text.clusters().join("\u{200B}"), body)
