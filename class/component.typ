#import "component/code.typ"
#import "component/href.typ"

#let tick(date) = {
  if type(date) == "string" {
    let (year, month, day) = date.split("-")
    date = datetime(year: int(year), month: int(month), day: int(day))
  }
  [#metadata((date: date)) <meta-tick>]
}

#let alias(..slugs) = [
  #metadata((slugs: slugs.pos())) <meta-alias>
]
