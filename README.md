# pandoc-lecturenotes

This is a set of filters for producing slides (for Deckset) and notes with embedded slides (for formatting with **ms** or LaTeX) from a single (Markdown) document.  The idea is similar to, e.g., `beamerarticle` but aims to be lightweight.

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

The content of the slide blocks is in Deckset’s Markdown variant, with extensions.

For producing slides, use the `deckset-slides.lua` filter with `commonmark+footnotes+pipe_tables+strikeout+tex_math_dollars` as target format.  If you use citeproc, add the `deckset-post-citeproc.lua` filter **after** the `--citeproc` option.

For producing notes for formatting with **ms** or LaTeX, use the `embed-slides.lua` filter.

Both filters are compatible with the [`scholarly-metadata` filter](https://github.com/pandoc/lua-filters/tree/master/scholarly-metadata).

© 2022 by Michael Piotrowski <mxp@dynalabs.de>

