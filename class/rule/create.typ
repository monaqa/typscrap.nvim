#let create-rule(name, default: it => it) = {
  let s = state("rule:" + name, default)

  let updater(new-cb: it => it, body) = context {
    let current = s.get()
    s.update(cb => new-cb)
    body
    s.update(cb => current)
  }

  (
    _state: s,
    current: () => context { s.get() },
    "show": it => context {
      let cb = s.get()
      cb(it)
    },

    clear: s.update(cb => (it => it)),
    without: updater.with(new-cb: it => it),

    apply: new-cb => s.update(cb => new-cb),
    apply-within: (new-cb, body) => updater(new-cb: new-cb, body),

    append: other-cb => s.update(cb => (it => other-cb(cb(it)))),
    append-within: (other-cb, body) => context {
    let current = s.get()
    s.update(cb => (it => other-cb(current(it))))
    body
    s.update(cb => current)
    },

    prepend: other-cb => s.update(cb => (it => cb(other-cb(it)))),
    prepend-within: (other-cb, body) => context {
    let current = s.get()
    s.update(cb => (it => current(other-cb(it))))
    body
    s.update(cb => current)
    },
  )
}
