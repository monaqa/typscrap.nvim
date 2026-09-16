#let chatbot(
  question,
  answer,
  bot-name: [Gemini],
  gutter: 5pt,
  q-width: 75%,
  a-width: 95%,
  q-block-args: arguments(),
  a-block-args: arguments(),
  name-box-args: arguments(),
  name-text-args: arguments(),
) = {
  grid(
    row-gutter: gutter,
    grid(
      columns: (1fr, q-width),
      none,
      block(
        width: 100%,
        fill: colors.bg.b0.lighten(50%),
        stroke: colors.bg.b1 + 1pt,
        inset: 10pt,
        radius: (top-right: 0pt, rest: 12pt),
        ..q-block-args,
        question,
      ),
    ),
    grid(
      columns: (a-width, 1fr),
      stack(
        box(
          inset: 5pt,
          fill: colors.fg.c2,
          stroke: colors.fg.c2 + 1.5pt,
          radius: 2pt,
          ..name-box-args,
          text(
            size: 0.95em,
            weight: 600,
            fill: white,
            ..name-text-args,
            bot-name,
          ),
        ),
        block(
          width: 100%,
          fill: colors.bg.g0.lighten(70%),
          stroke: colors.fg.c2 + 1.5pt,
          inset: 10pt,
          radius: (top-left: 0pt, rest: 12pt),
          ..a-block-args,
          [
            #set heading(offset: 2)
            #answer
          ],
        ),
      ),
      none,
    ),
  )
}
