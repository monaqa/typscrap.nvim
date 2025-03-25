#import "@preview/diagraph:0.3.2": render

#let nodename(indices) = "node_" + indices.map(i => str(i)).join("_")

#let to_attr(d, sep: " ") = {
  d.pairs().map(((k, v)) => k + "=" + repr(v)).join(sep)
}

#let item_body_to_data(body, indices) = {
  if body.has("children") {
    let children = body.children
    let items = children.filter(c => c.func() == list.item).enumerate().map((
      (idx, item),
    ) => item_body_to_data(item.body, indices + (idx,)))
    let metadata = children.find(c => c.func() == metadata)
    let text = children.filter(c => c.func() != list.item).join()
    (
      indices: indices,
      text: text,
      metadata: if metadata != none {
        metadata.value
      } else {
        none
      },
      items: items,
    )
  } else {
    (indices: indices, text: body, metadata: none, items: ())
  }
}

#let data_to_gviz(data) = {
  let self = nodename(data.indices)
  if data.metadata != none {
    self + " [" + to_attr(data.metadata) + "]\n"
  } else {
    self + "\n"
  }
  for child in data.items {
    let child_nodename = nodename(child.indices)
    data_to_gviz(child)
    self + " -- " + child_nodename + "\n"
  }
}

#let data_to_labels(data) = {
  let self = nodename(data.indices)
  let d = (:)
  d.insert(self, data.text)
  d
  for child in data.items {
    let child_nodename = nodename(child.indices)
    data_to_labels(child)
  }
}

#let draw-tree(
  body,
  root-text: [],
  root-metadata: (shape: "point"),
  default-attrs: (layout: "twopi", ranksep: 1.0),
  default-node-attrs: (:),
  default-edge-attrs: (:),
  ..args,
) = {
  let data = item_body_to_data(body, ())
  data.text = root-text
  data.metadata = root-metadata
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
