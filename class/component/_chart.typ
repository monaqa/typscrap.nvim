#import "@preview/diagraph:0.3.2": render

#let nodename(name, indices) = if name == auto {
  "node_" + indices.map(i => str(i)).join("_")
} else {name}

#let to_attr(d, sep: " ") = {
  d.pairs().map(((k, v)) => k + "=" + repr(v)).join(sep)
}

#let item_body_to_data(body, indices) = {
  if body.has("children") {
    let children = body.children
    let items = children.filter(c => c.func() == list.item).enumerate().map((
      (idx, item),
    ) => item_body_to_data(item.body, indices + (idx,)))
    let text = children.filter(c => c.func() != list.item).join()
    let (name, attrs, to) = children.filter(c => c.func() == metadata).fold(
      (name: auto, attrs: (:), to: ()), (acc, item) => {
        if "name" in item.value {acc.name = item.value.name}
        if "attrs" in item.value {acc.attrs = arguments(..acc.attrs, ..item.value.attrs).named()}
        if "to" in item.value {
          let edges = if type(item.value.to) == str or type(item.value.to) == dictionary {
            (item.value.to,)
          } else {item.value.to}
          acc.to = (..acc.to, ..edges)
        }
        acc
      }
    )
    (
      indices: indices,
      name: name,
      text: text,
      attrs: attrs,
      to: to,
      items: items,
    )
  } else {
    (indices: indices, name: auto, text: body, attrs: (:), to: (), items: ())
  }
}

#let data_to_gviz(data) = {
  let self = nodename(data.name, data.indices)
  if data.attrs != none {
    self + " [" + to_attr(data.attrs) + "]\n"
  } else {
    self + "\n"
  }
  for child in data.items {
    let child_nodename = nodename(child.name, child.indices)
    data_to_gviz(child)
    self + " -- " + child_nodename + "\n"
  }
  for e in data.to {
    let (name, attrs) = if type(e) == dictionary {
      e
    } else {
      (name: e, attrs: (dir: "forward", style: "dashed"))
    }
    self + " -- " + name + "[" + to_attr(attrs) + "]\n"
  }
}

#let data_to_labels(data) = {
  let self = nodename(data.name, data.indices)
  let d = (:)
  d.insert(self, data.text)
  d
  for child in data.items {
    let child_nodename = nodename(child.name, child.indices)
    data_to_labels(child)
  }
}

#let draw-tree(
  body,
  root-text: [],
  root-attrs: (shape: "point"),
  default-attrs: (layout: "twopi", ranksep: 1.0),
  default-node-attrs: (:),
  default-edge-attrs: (:),
  ..args,
) = {
  let data = item_body_to_data(body, ())
  data.text = root-text
  data.attrs = root-attrs
  let s = data_to_gviz(data)
  let labels = data_to_labels(data)
  render(
    {
      "graph tree { "
      to_attr(default-attrs) + "\n"
      "node [" + to_attr(default-node-attrs) + "]\n"
      "edge [" + to_attr(default-edge-attrs) + "]\n"
      s
      "}"
    },
    labels: labels,
    ..args,
  )
}

#let node(..args) = {metadata(args.named())}
