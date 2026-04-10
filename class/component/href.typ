#import "block.typ": labeled-text
#import "../util.typ": to-string

#let parse_url(url) = {
  let match = url.match(regex("http[s]?://([^/]+)([^?]+)?([#?].*)?"))
  if match == none {
    return (domain: url)
  }
  let (captures: (domain, paths, query)) = match
  if paths == none {
    paths = ""
  }
  let path_ary = paths.trim("/").split("/")
  return (domain: domain, paths: paths, path_ary: path_ary, query: query)
  // let body = url.trim(regex("http[s]?://"))
  // let (domain, ..path_ary) = body.split("/")
  // let paths = path_ary.join("/")
  // return (domain: domain, paths: paths, path_ary: path_ary)
}

#let is_raw_link(it) = {
  return it.dest == it.body.at("text", default: none)
}

#let default_link_style(it, raw: false) = {
  if raw or it.func() == link and is_raw_link(it) {
    return text(fill: blue, font: "CommitMono-height105", size: 0.85em, it)
  } else {
    return text(fill: blue, it)
  }
}

#let github_link_converter(it) = {
  let icon = text(font: "Hack Nerd Font", [])
  let icon_color = rgb("#24292e")

  let info = {
    let url_info = parse_url(it.dest)
    let user_name = url_info.path_ary.at(0, default: none)
    let repo_name = url_info.path_ary.at(1, default: none)
    let kind = url_info.path_ary.at(2, default: none)
    let num = url_info.path_ary.at(3, default: none)

    let title = {
      let title_str = to-string(it.body).split("·")
      if title_str.len() == 1 {
        it.body
      } else {
        [#title_str.at(0).trim()]
      }
    }

    (
      raw: is_raw_link(it),
      kind: kind,
      title: title,
      user: user_name,
      repo: repo_name,
      num: num,
      path: url_info.paths,
    )
  }

  let repo_info_body = if info.num != none {
    if info.kind == "blob" and info.num.len() >= 7 {
      [#strong(info.repo) #info.kind\##info.num.slice(0, 7)]
    } else {
      [#strong(info.repo) #info.kind\##info.num]
    }
  } else {
    if info.repo != none {
      info.repo
    } else {
      none
    }
  }

  if info.raw {
    labeled-text(
      label: text(fill: white)[#icon#h(0.4em)],
      stroke: icon_color,
      fill: icon_color.lighten(90%),
      top-edge: 85%,
      bottom-edge: -15%,
      default_link_style(
        text(
          font: "CommitMono-height105",
          size: 0.9em,
        )[#if repo_info_body != none {
            repo_info_body
          } else {
            it.body
          }],
      ),
    )
  } else {
    labeled-text(
      label: text(
        fill: white,
        font: "CommitMono-height105",
        size: 0.8em,
      )[#icon#h(0.4em)#repo_info_body],
      stroke: icon_color,
      fill: icon_color.lighten(90%),
      top-edge: 85%,
      bottom-edge: -15%,
      default_link_style(
        text(size: 0.85em, info.title),
      ),
    )
  }
}

#let default_link_converters = (
  "github.com": github_link_converter,
)

#let pretty_link(link_converters: (:), link_style: default_link_style, it) = {
  if type(it.dest) != str {
    return it
  }

  // 再帰による無限ループを防ぐための措置。
  let _link_processed_flag = metadata((_internal_link_processed: true))
  let _metadata = it.body.at("children", default: ()).at(0, default: (:)).at(
    "value",
    default: (:),
  )
  let processed = _metadata.at("_internal_link_processed", default: false)
  if processed {
    return it
  }

  // http:// ... と直書きしてる
  let (domain: domain) = parse_url(it.dest)
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
