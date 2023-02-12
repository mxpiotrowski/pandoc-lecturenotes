# pandoc-lecturenotes

This is a set of filters for producing slides (for [Deckset](https://www.deckset.com/)) and notes with embedded slides (for formatting with **ms** or LaTeX) from a single (Markdown) document.  The idea is similar to, e.g., `beamerarticle` but aims to be lightweight.

Within the document, slides are contained in blocks with the class `slide` like this:

```
::: slide
# Inline Quotes

You can also use a quote together with paragraph text or other elements on the slide:

> The best way to predict the future is to invent it  
-- Alan Kay

Prefix the author of the quote with `--`, or leave it out if it's anonymous.
:::
```

The content of the slide blocks is in Deckset’s Markdown variant, with some extensions and some limitations.

For producing slides, use the `deckset-slides.lua` filter with `commonmark+footnotes+pipe_tables+strikeout+tex_math_dollars` as target format.  If you use citeproc, add the `deckset-post-citeproc.lua` filter **after** the `--citeproc` option.

For producing notes with embedded slides for formatting with **ms** or LaTeX, use the `embed-slides.lua` filter.

⚠ Starting with [Pandoc 3.0](https://pandoc.org/releases.html#pandoc-3.0-2023-01-18), the `implicit_figures` extension generates nodes of the new `Figure` type.  This is a major change that breaks the `embed-slide.lua` filter; you currently **must** turn off this extension when producing lecture notes, e.g., by specifying `-f markdown-implicit_figures`.  The `deckset-slides.lua` filter has been adapted and should work with or without `implicit_figures`.

⚠ `ms` output currently doesn’t work.

You can exclude slides from the notes by adding the `presentation` class, for example:

```
::: {.slide .presentation}
Presentation only
:::
```

You can exclude all slides from the notes by setting the `showslides` metadata field to `false`. 

The `embed-slides.lua` filter aims to produce useful renderings of the slides, but obviously cannot reproduce everything that Deckset does, especially when it comes to images.

Both filters are compatible with the [`scholarly-metadata` filter](https://github.com/pandoc/lua-filters/tree/master/scholarly-metadata).

## Formatting `sample.md`

Do `make sample-deckset.md` to produce the slides version of `sample.md`, `make sample-latex.pdf` to produce a LaTeX-formatted PDF version, and `make sample-ms.pdf` for the groff-formatted PDF version (note that the version of groff shipped with macOS is too old for Pandoc).

© 2022 by Michael Piotrowski <mxp@dynalabs.de>

