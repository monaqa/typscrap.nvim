// content を string に変換する。
#let to-string(it) = {
  if type(it) == str {
    return it
  }
  if type(it) != content {
    return str(it)
  }

  if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] {
    " "
  }
}
