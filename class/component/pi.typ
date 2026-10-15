#import "@preview/datehog:0.1.1" as dh
#import "@preview/cmarker:0.1.10"
#import "table.typ": termtable

#let pi-icon(..args) = {
  let palette = (
    P: (240, 144, 130, 255),
    B: (77, 154, 191, 255),
    Y: (241, 190, 88, 255),
    ".": (0, 0, 0, 0),
  )
  let pixels = ("PPP.", "B.P.", "BB.Y", "B..Y")
  let data = bytes(pixels.join("").clusters().map(p => palette.at(p)).flatten())

  box(image(data, width: 2cm, ..args, format: (encoding: "rgba8", width: 4, height: 4)))
}

#let session(path) = {
  let source = read(path).trim()

  if source == "" {
    return [#box(baseline: 0.20em, pi-icon(width: 1.1em)) #path]
  }

  let entries = source.split("\n").map(line => json(bytes(line)))
  let header = entries.find(entry => entry.type == "session")
  let users = entries.filter(
    entry => entry.type == "message" and entry.message.role == "user",
  )

  if users.len() == 0 {
    return [#box(baseline: 0.20em, pi-icon(width: 1.1em)) #path]
  }

  let preview(message) = {
    let content = message.content
    if type(content) == str {
      content
    } else {
      content.filter(part => part.type == "text").map(part => part.text).join("")
    }
  }

  let timestamp = dh.to-typst-datetime(dh.parse(header.timestamp)) + duration(hours: 9)

  if users.len() >= 2 {
    termtable[
      / #pi-icon(width: 1em): #path
      / 開始: #timestamp.display("[year]/[month]/[day] [hour]:[minute]")
      / 会話数: #users.len()
      / 最初: #cmarker.render(preview(users.first().message))
      / 最新: #cmarker.render(preview(users.last().message))
    ]
  } else {
    termtable[
      / #pi-icon(width: 1em): #path
      / 開始: #timestamp.display("[year]/[month]/[day] [hour]:[minute]")
      / 最新: #cmarker.render(preview(users.last().message))
    ]
  }
}
