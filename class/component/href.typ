#let parse_url(url) = {
  let body = url.trim(regex("http[s]?://"))
  let (domain, ..path_ary) = body.split("/")
  let paths = path_ary.join("/")
  return (domain: domain, paths: paths, path_ary: path_ary)
}

#let is_raw_link(it) = {
  return it.dest == it.body.at("text", default: none)
}

#let default_link_style(it) = {
  if is_raw_link(it) {
    return text(fill: blue, font: "CommitMono-height105", size: 0.85em, it)
  } else {
    return text(fill: blue, it)
  }
}

#let github_link_converter(it) = {
  let icon = text(font: "Hack Nerd Font", [])
  let icon_color = rgb("#24292e")

  if not is_raw_link(it) {
    return [#text(fill: icon_color, icon)#h(0.5em)#default_link_style(it)]
  }

  let info = parse_url(it.dest)
  let user_name = info.path_ary.at(0, default: none)
  let repo_name = info.path_ary.at(1, default: none)
  let kind = info.path_ary.at(2, default: none)

  let _text
  if user_name == none or repo_name == none {
    _text = info.paths
  } else {
    _text = [#user_name/#strong(repo_name)]
    if kind == "pull" {
      let num = info.path_ary.at(3, default: none)
      let prefix = if num != none {[PR\##num:]} else {[PRs:]}
      _text = [#prefix #_text]
    }
    if kind == "issues" {
      let num = info.path_ary.at(3, default: none)
      let prefix = if num != none {[Issue\##num:]} else {[Issues:]}
      _text = [#prefix #_text]
    }
  }

  return text(font: "CommitMono-height105", box(
    fill: icon_color,
    inset: (x: 4pt, bottom: 1pt),
    outset: (top: 4pt, bottom: 3pt),
    radius: 4pt,
    text(fill: white, size: 0.75em, weight: 400, [#icon #_text])
  ))
}

#let default_link_converters = ("github.com": github_link_converter)

#let pretty_link(link_converters: (:), link_style: default_link_style, it) = {
  if type(it.dest) == location {
    return it
  }

  // 再帰による無限ループを防ぐための措置。
  let _link_processed_flag = metadata((_internal_link_processed: true))
  let _metadata = it.body.at("children", default: ()).at(0, default: (:)).at("value", default: (:))
  let processed = _metadata.at("_internal_link_processed", default: false)
  if processed {
    return it
  }

  // http:// ... と直書きしてる
  let (domain: domain,) = parse_url(it.dest)
  let converter = link_converters.at(domain, default: none)
  if converter != none {
    return link(it.dest, [#_link_processed_flag#converter(it)])
  }

  link_style(it)
}

#let emph_link(it) = locate(loc => {
  let slug = lower(it.body.text)
  let dest = query(heading, loc).find(x => lower(x.body.text) == slug)
  if dest != none {
    text(fill: blue, link(dest.location(), [[#it]]))
  } else {
    text(fill: red.darken(40%), [[#it]])
  }
})
