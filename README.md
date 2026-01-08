# pandoc-lecturenotes

This is a set of filters for producing slides (using any of the slide formats supported by Pandoc or [Deckset](https://www.deckset.com/)) and lecture notes with or without embedded slides (in PDF, using LaTeX or—with limitations—**ms**) from a single Markdown document.  The idea is similar to, e.g., `beamerarticle` but aims to be lightweight.

Within the document, slides are contained in blocks with the class `slide` like this:

```
::: slide

# The Future

> The best way to predict the future is to invent it  
-- Alan Kay

:::
```

For producing slides in the formats natively supported by Pandoc (e.g., reveal.js), use the `native-slides.lua` filter and the desired target format (e.g., `-t revealjs`).  The `native-slides.lua` filter should typically come early in the filter pipeline, in any case before `--citeproc`, to avoid references that don’t occur on the slides to appear in the list of references.  The slide blocks can in principle contain any construct supported by Pandoc.

For producing slides for Deckset, use the `deckset-slides.lua` filter with `commonmark+footnotes+pipe_tables+strikeout+tex_math_dollars` as target format.  If you use citeproc, add the `deckset-post-citeproc.lua` filter **after** the `--citeproc` option.  The content of the slide blocks is in Deckset’s Markdown variant, with some extensions and some limitations.

For producing notes with embedded slides for formatting with **ms** or LaTeX, use the `embed-slides.lua` filter.  You can exclude slides from the notes by adding the `presentation` class, for example:

```
::: {.slide .presentation}
This slide will only appear in the presentation.
:::
```

You can exclude _all_ slides from the lecture notes by setting the `showslides` metadata field to `false`.   You can also exclude images, divs, and code blocks from slides by adding the `lecturenotes` class; for example, this link will only appear in the lecture notes:

```
![](https://youtu.be/…){.lecturenotes}
```

This can be used to explicitly use different images for the presentation and the lecture notes.  But you can also use it, for example, to have Deckset include a video from the filesystem (so you don’t depend on a network connection for the presentation) and to include a YouTube link on the lecture notes.

The `embed-slides.lua` filter aims to produce useful renderings of the slides, but obviously cannot reproduce everything that Deckset does, especially when it comes to images.

Both filters are compatible with the [`scholarly-metadata` filter](https://github.com/pandoc/lua-filters/tree/master/scholarly-metadata).

## Formatting `sample.md`

Note: `sample.md` currently assumes Deckset.

Do `make sample-deckset.md` to produce the slides version of `sample.md`, `make sample-latex.pdf` to produce a LaTeX-formatted PDF version, and `make sample-ms.pdf` for the groff-formatted PDF version (note that the version of [groff](https://www.gnu.org/software/groff/) shipped with macOS is too old for Pandoc, you need to install a more recent version).

© 2022 by Michael Piotrowski <mxp@dynalabs.de>

