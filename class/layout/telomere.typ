#let draw_tick_range(y_start, y_end, date) = {
  let left_margin = 16pt
  let baseline = 0pt

  let max_days = 30
  let diff_days = (datetime.today() - date) / duration(days: 1)

  let tick_color = {
    let base_color = rgb("#2ecc40")
    if date.weekday() == 6 {
      base_color = blue
    } else if date.weekday() == 7 {
      base_color = red
    }

    let diff_ratio = 80% * calc.min(1, calc.pow(diff_days / max_days, 1 / 2))
    color.mix((base_color, 100% - diff_ratio), (luma(90%), diff_ratio))
  }

  let tick_width = {
    let diff_ratio = 90% * calc.min(1, diff_days / max_days)
    4pt * (100% - diff_ratio)
  }

  let content_date = text(
    size: 8pt,
    fill: tick_color,
    font: "Noto Serif",
    number-type: "old-style",
    date.display("[year]-[month]-[day]"),
  )

  place(left + top, dx: -(left_margin - tick_width / 2), line(
    start: (0pt, y_start + 0.5pt + baseline),
    end: (0pt, y_end - 0.5pt + baseline),
    stroke: tick_color + tick_width,
  ))
  place(
    dx: -(48pt + left_margin),
    dy: (y_start + y_end) / 2 - 0.25em,
    left + top,
    content_date,
  )
}

#let telomere(loc) = {
  let offset = loc.position()
  let ticks = query(<meta-tick>, loc).enumerate().map(((idx, tick)) => (
    idx: idx,
    date: tick.value.date,
    page: tick.location().page(),
    y: tick.location().position().y,
  ))

  let last_tick_on_prev_page = ticks.filter((tick) => tick.page < loc.position().page).at(-1, default: none)
  let ticks_to_display = ticks.filter((tick) => tick.page == loc.position().page)

  if last_tick_on_prev_page != none {
    ticks_to_display.insert(0, (
      idx: last_tick_on_prev_page.idx,
      date: last_tick_on_prev_page.date,
      y: loc.position().y + 1.0cm,
    ))
  }

  for tick in ticks_to_display {
    let next_tick = ticks.at(tick.idx + 1, default: none)
    if next_tick == none {
      // 最後の tick は終わりの場所を示すためだけにある
      break
    }

    if tick.date != none {
      if next_tick.page != loc.position().page {
        draw_tick_range(tick.y, loc.position().y + 841.89pt - 4.0cm, tick.date)
        continue
      }
      draw_tick_range(tick.y, next_tick.y, tick.date)
    }
  }
}
