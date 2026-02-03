---
title: "pandoc-lecturenotes"
author:
    - "Michael Piotrowski"
lang: "en-US"
papersize: a4
geometry: margin=2.5cm
shownotes: true
colorlinks: true
reference-section-title: "Bibliography"
footer: |
    `Use *emphasis* and ~~other~~ text styles if you like`
slidenumbers: true
subtitle: "Generating lectures and notes from a single document"
showslides: true
logo: "assets/logo.png"
titlegraphic: "assets/image1.jpg"
theme: Fira, 3
footer-style: #2F2F2F, alignment(right), line-height(8), text-scale(1.5), Avenir Next Regular
---

# Deckset Features

Here we reproduce most of the examples from the [Deckset documentation](https://docs.deckset.com/).  When using the `deckset-slides.lua` filter, the content of slides is *not* simply output verbatim, but it is parsed and reserialized by Pandoc.  The examples thus serve to verify

1. that Deckset’s features can be used on slides and
2. that they are reasonably reproduced on embedded slides.

Note that the goal is *not* that embedded slides *look* like Deckset would format them; this would be pointless.  The goal is rather that they are embedded in a way that is useful.  There are obviously a few limitations; some things simply cannot be reproduced in static media.

## Headings

::: slide
# Large Heading
:::

::: slide
## Regular Heading
:::

::: slide
### Small Heading
:::

::: slide
#### Tiny Heading
:::

::: slide
## Combine Headings

### Of Different Sizes
:::

::: slide
# [fit] Make Headings Fit Onto

# [fit] The Slide
:::

## Lists

::: slide
# Unordered Lists

- Start each bullet point
- with a dash to create
- an unordered list
:::

::: slide
# Ordered Lists

1. Start each item with
1. a number followed by a dot
1. to create an ordered list
:::

::: slide
# Nested Lists

- You can create nested lists
    1. by indenting
    1. each item with
    1. 4 spaces
- It's that simple
:::

## Text Styles

::: slide
# Asterisk Emphasis

Use single asterisks around text to *emphasise it*.

Or use double asterisks for a **strong emphasis** style.
:::

::: slide
# Underscore Emphasis

Alternatively, you can also use underscores to emphasize:

Wrap text in single underscores to _emphasize it_. Or use double underscores for the alternative __strong emphasis style__.
:::

::: slide
# Combined Emphasis (not supported by Pandoc)

Combining underscores with asterisks lets us mix and match the emphasis styles. Play with it — some themes have additional style options for those combinations:

- _**Style 1**_
- __*Style 2*__
- __**Style 3**__
:::

::: slide
# The same *styles* work in **headings**, too.
:::

Deckset uses `<sup>…</sup>` and `<sub>…</sub>` for superscripts and subscripts; this is passed through to slides, but not translated when the slides are embedded.  We recommend to use Pandoc notation (`^…^` and `~…~`) instead.

::: slide
# More Styles

- ~~Strikethrough~~
- Super<sup>script</sup> (Pandoc: Super^script^)
- Sub<sub>script</sub> (Pandoc: Sub~script~)
- `Inline code`
:::

## Quotes

One of the main benefits of using Pandoc is that we can use real bibliographic references; see the section on [bibliographic references](#bibliographic-references) below.

To make sure that blockquotes are rendered correctly, make sure there is a “hard line break” before the attribution by ending the previous line with two or more spaces.

::: slide
> The best way to predict the future is to invent it  
-- Alan Kay
:::

::: slide
# Inline Quotes

You can also use a quote together with paragraph text or other elements on the slide:

> The best way to predict the future is to invent it  
-- Alan Kay

Prefix the author of the quote with `--`, or leave it out if it's anonymous.
:::

## Links

<!--

::: slide
# Link to External Resources
<a name="link-target"/>

In case you're looking for something, you could use [Google](http://google.com) or [Wikipedia](http://wikipedia.com).

Links will be clickable in exported PDFs as well!
:::

In addition to HTML syntax, we also support (and prefer) an ID attribute on the slide div, for example:

```
::: {.slide #link-target}
```

Anchors are exported to Deckset, LaTeX, and ms. 

::: slide
# Links Between Slides

Define an anchor on the slide you want to link to using standard HTML syntax:

`<a name="link-target"/>`

Then you can link to this [slide](#link-target) easily.
:::

-->

## Code Blocks

::: slide
# Syntax Highlighting

Use GitHub style fenced code blocks to specify the language.

```javascript
$.ajax({
  url: "/api/getWeather",
  data: {
    zipcode: 97201
  },
  success: function( data ) {
    $( "#weather-temp" ).html( "" + data + " degrees" );
  }
});
```
:::

We support `[.code-highlight: …]` but prefer attributes on the slide div.  This is not translated to LaTeX and ms.

::: slide
# Highlight Lines of Code

To put the focus on specific lines of your code block, use the following command:

```
[.code-highlight: 2]
```

[.code-highlight: 2]

```javascript
$.ajax({
  url: "/api/getWeather",
  data: {
    zipcode: 97201
  },
  success: function( data ) {
    $( "#weather-temp" ).html( "" + data + " degrees" );
  }
});
```
:::

::: slide
# Highlight Lines of Code

You can also highlight a range of lines:

[.code-highlight: 2, 6-8]

```javascript
$.ajax({
  url: "/api/getWeather",
  data: {
    zipcode: 97201
  },
  success: function( data ) {
    $( "#weather-temp" ).html( "" + data + " degrees" );
  }
});
```
:::

This is not translated to LaTeX and ms.

::: slide
# Step through Highlighted Lines of Code

When presenting, you can step through multiple highlights incrementally. Place as many `[.code-highlight]` commands above a code block in the order you would like the lines of code to be highlighted when presenting.

[.code-highlight: none]
[.code-highlight: 2]
[.code-highlight: 6-8]
[.code-highlight: all]

```javascript
$.ajax({
  url: "/api/getWeather",
  data: {
    zipcode: 97201
  },
  success: function( data ) {
    $( "#weather-temp" ).html( "" + data + " degrees" );
  }
});
```
:::

Automatic scaling is not supported in LaTeX or ms.

::: slide
# Automatic Scaling

Don’t worry if your code is slightly too long. Deckset scales code blocks to fit automatically.

```ruby
def establish_connection(spec = nil)
  spec     ||= DEFAULT_ENV.call.to_sym
  resolver =   ConnectionAdapters::ConnectionSpecification::Resolver.new configurations
  spec     =   resolver.spec(spec)

  unless respond_to?(spec.adapter_method)
    raise AdapterNotFound, "database configuration specifies nonexistent #{spec.config[:adapter]} adapter"
  end

  remove_connection
  connection_handler.establish_connection self, spec
end
```
:::

::: slide
# Inline code

Use code within normal text by enclosing it in backticks.

For example: `func map<A, B>(x: A?, f: A -> B) -> B?`
:::

## Tables

::: slide
# Tables

Cells are separated by pipes `|`.

Table headers are separated from the table body with a line of three dashes `---`.

| Header 1 | Header 2 | Header 3 |
| --- | --- | --- |
| Cell 1 | Cell 2 | Cell 3 |
| Cell 4 | Cell 5 | Cell 6 |
:::

::: slide
Text Alignment: With `:---:` and `---:` you can center or right align the cell content.

|   Header 1  |    Header 2   |   Header 3   |
| ----------- | :-----------: | -----------: |
| Cell        |    _Cell_     |    *Cell*    |
| Cell        |   **Cell**    |   __Cell__   |
:::

## Formulas

::: slide
# Formulas

Easily include mathematical formulas by enclosing TeX commands in `$$` delimiters. Deckset uses MathJax to translate TeX commands into beautiful vector graphics.

$$
\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)
$$
:::

::: slide
# Inline Formulas

You can also include Formulas in paragraph text. Deckset takes care of adjusting the font size and color to match the surrounding text, for example:

The slope $$a$$ of the line defined by the function $$f(x) = 2x$$ is $$a = 2$$.
:::

There is no “autoscaling” in LaTeX or ms; TeX and eqn will do whatever they do in such cases.

::: slide
# Formula Autoscaling

Don’t worry if your equations get really complex. Deckset will scale them down to fit onto the slide.

$$
1 +  \frac{q^2}{(1-q)}+\frac{q^6}{(1-q)(1-q^2)}+\cdots =
\prod_{j=0}^{\infty}\frac{1}{(1-q^{5j+2})(1-q^{5j+3})},
\quad\quad \text{for $|q|<1$}.
$$
:::

## Emojis

This works in Deckset but isn’t currently converted to LaTeX or ms, even thought it should be easy to do (i.e., outputting the corresponding Unicode code point).

Typst supports named emoji, but the names are different… (see [Emoji Symbols](https://typst.app/docs/reference/symbols/emoji/)).

::: slide
# Emojis

Deckset supports Slack style emojis, e.g.: `:sunny:` `:umbrella:` `:sunflower:` `:cat:` `:smile:`

Deckset supports emojis! :umbrella: :sunflower: :cat: :smile: :thumbsup:

Please refer to this [Emoji Reference Markdown file](http://deckset-assets.s3.amazonaws.com/emoji-reference.md) to see which emoji are supported in Deckset. There are a few favourites that aren’t part of Unicode yet, so we cannot support them.
:::

## Footers and Slide Numbers

To globally enable or disable slide numbers and to set a footer on slides, use the following metadata keys (e.g., in the YAML header):

- `slidenumbers` (`true` or `false`)
- `footer`

To include formatting in the footer, use the following approach to ensure it gets through Pandoc:

```
footer: |
    `Use *emphasis* and ~~other~~ text styles if you like`
```

If you want to disable footers or slide numbers on individual slides, you can do so by using per slide commands (see below).

All these settings are ignored for embedded slides.

## Footnotes

You can have footnotes on slides and in the notes, but since this is really *one* document, no duplicate identifiers are allowed (the number to be displayed is chosen by Deckset or the formatter anyway).  The footnote text does not need to be on the slide, but can be anywhere.

::: slide
# Footnotes

Footnotes are a breeze, for example:

Most of the time, you should adhere to the APA citation style[^1].

Note that footnote references have to be *unique in the markdown file*. This means, that you can also reference footnotes from any slide, no matter where they are defined.

[^1]: For more details on the citation guidelines of the American Psychological Association check out their [website](https://www.library.cornell.edu/research/citation/apa).

:::

Named references with spaces are *not* supported by Pandoc, but they are not useful anyway, as we have real citations.  You can use named references [as long as they do not contain spaces, tabs, or newlines](https://pandoc.org/MANUAL.html#footnotes).

::: slide
# Named References (Unsupported)

Instead of just numbers, you can also name your footnote references[^Wiles, 1995].

[^Wiles, 1995]: [Modular elliptic curves and Fermat's Last Theorem](http://math.stanford.edu/~lekheng/flt/wiles.pdf). Annals of Mathematics 141 (3): 443–551.

:::

## Controlling Line Breaks

The `deckset-slides.lua` filter converts soft line breaks into hard ones to enable the behavior shown on the next slide.  The `embed-slides.lua` filter does not do this.  Both filters support `<br>`.

::: slide
# Controlling Line Breaks

In paragraph text, Deckset respects when you start a
new
line.

This can come in handy in situations where you need more control over how text is broken up into multiple lines.
:::

::: slide
# Use `<br>` for<br>line<br>breaks

You can use the HTML tag `<br>` to insert line breaks in elements that cannot contain regular new lines, such as headings or footers.
:::

## Auto-Scaling

As for the other global options described [above](#footers-and-slide-numbers), the `autoscale` option goes into the metadata instead.  It does not have an effect on embedded slides.

::: slide
# Auto-Scaling

At times you have to fit more content onto one slide than the default font sizes allow for.

Deckset comes with an option to auto-scale paragraph text, lists, and other body content down to fit onto the slide. To enable this behavior put

`autoscale: true`

on the first line of your markdown file.
:::

## Columns

Columns can easily be converted to Typst, but it would be a major effort in LaTeX or ms.  In these formats, columns are rendered vertically.

::: slide
# Columns

In order to layout your content in columns, use the `[.column]` command to start a new column.

[.column]

# The First column

[.column]

# Second column.

:::

Column widths are automatically generated using the available space divided evenly by the number of columns specified.

You can add as many columns as you like, but the more you add, the smaller the available width will be.

Combine Columns with Auto-Scaling to automatically scale down the text size to fit on the side.

# Media

## Background Images

Full Background Image

::: slide
![](assets/image1)
:::

Fit Background Image

::: slide
![fit](assets/image1)
:::

Multiple Background Images.  Deckset doesn’t require that each image is a separate paragraph, but this is the same issue as with multiple per-slide commands—so, for Pandoc, insert a newline between them.

Also, this does not easily convert to LaTeX or ms—this is essentially the same problem as with multiple columns.

::: slide

![](assets/image1)

![](assets/image2)

![](assets/image3)
:::

## Text on Images

None of the following features are converted to LaTeX or ms.

::: slide
![](assets/image1)

# Text on Images

Setting text on images applies a filter to the image to make the text more readable.
:::

::: slide
![original](assets/image1)

# Disable Filter
:::

::: slide
![left filtered](assets/image1)

# Force Apply Filter

Use the `filtered` keyword to apply the theme's filter to an image that isn't filtered by default.
:::

::: slide
![original 250%](assets/image1)

# Zoom In
:::

Split slides are to some extent rendered in LaTeX.

::: slide
![right fit](assets/image1)

# Split Slides

Combine `left` or `right` with the `fit` keyword or a percentage to adjust the image scaling.
:::

## Inline Images

Combine Text and Images

::: slide
# Combine Text and Images

![inline](assets/image1)
:::

::: slide
# Fill the Slide

![inline fill](assets/image1)
:::

Custom scaling could perhaps be converted to LaTeX and ms, but it’s not clear to me what the scaling refers to.  It’s currently not handled.

::: slide
# Custom Scaling

![inline 50%](assets/image1)
:::

Image grids would be very hard to convert to LaTeX and ms; we would first need to identify arrangements that are treated as image grids by Deckset and then work out an equivalent arrangement.  This is currently not handled.

::: slide
# Image Grids

![inline fill](assets/image2)![inline fill](assets/image3)  
![inline fill](assets/image1)
:::

One problem, however, is that not all images may fit onto the page.  A workaround for LaTeX output is to add a Pandoc size attribute, which is removed by the Deckset filter, e.g.:

```
::: slide
# Image Grids (test for LaTeX output)

![inline fill](assets/image2){width=30%}![inline fill](assets/image3){width=30%}  
![inline fill](assets/image1){width=30%}
:::
```

## Videos

Audio, video and all images with Web links are replaced with a placeholder in LaTeX and ms output.

::: slide
![](assets/video1.mp4)
:::

::: slide
# Inline Videos

![inline](assets/video1.mp4)
:::

::: slide
# YouTube Embeds!

![](https://youtu.be/v3M0SJ2sJqg)

You can also use URL parameters like `?t=30s` to specify a start time for the clip.
:::

::: slide
![left](assets/video1.mp4)

# Video Layout Control

Use the same layout modifiers as with images to control the positioning of videos.

- `left` and `right`
- `fit` and `fill`
- Percentage sizing, e.g. `50%`
- `hide` to hide the video. Audio will play regardless.
:::

::: slide
![right autoplay mute](assets/video1.mp4)

# Video Playback Control

Control video playback by using one of those directives:

- `autoplay`
- `loop`
- `mute`
:::

## Audio

Audio is replaced with a placeholder in LaTeX and ms output.

::: slide
# Audio

To add audio files to your presentation, add them to your Markdown like so:

![](assets/pacman.au)

Your operating system’s file type icon will be used as a visual representation of the audio file.
:::

### Audio Layout Control

Use the same layout modifiers as with images to control the positioning of audio file icons.

- `left` and `right`
- `fit` and `fill`
- Percentage sizing, e.g. `25%`
- `hide` to hide the visual representation. Audio will play regardless.

### Audio Playback Control

Control audio playback by using one of those directives:

- `autoplay`
- `loop`
- `mute`

## Presenter Notes

Deckset turns every paragraph that starts with a `^` into presenter notes and doesn’t show this text on the slides.

You’ll see these notes on the presenter display (with two screens connected) or by using the rehearsal mode.

To preview your presenter notes in the main application window, you can turn them on by selecting `Toggle Presenter Notes` from the `View` menu.

To start another presenter note paragraph, prefix it with a caret again. Deckset will automatically scale the notes down to fit onto the presenter display in case you have a lot of text.

Example:

::: slide
# My slide title

^ This is a presenter note.
:::

Presenter notes are not shown for embedded slides.

### Customize the display of presenter notes

To customize the style of presenter notes, in both Presenter and Rehearsal modes and in exported documents, you may use the `presenter-notes` command like so:

```
presenter-notes: text-scale(2), alignment(left|right|center), Helvetica
```

You may also use this command on a single slide, like so:

```
[.presenter-notes: text-scale(2), alignment(left|right|center), Helvetica]
```

::: {.slide presenter-notes="text-scale(2), alignment(right), Helvetica Bold"}
This slide has a customized presenter note.

^ This is a presenter note.
:::

# Additional Features

## Title Slide

A title slide is automatically generated by the `deckset-slides.lua` filter using information from the metadata (title, subtitle, date, author); if the `scholarly-metadata.lua` filter is used, affiliations and e-mail addresses are also added.  Footer, slide numbers and slide count are turned off for the title slide.

You can specify an image file name in the metadata option `logo` to insert the following code above the text (here for the file name `assets/logo.png`); the image will be displayed in the top left side of the title slide:

```
![left inline](assets/logo.png)
```

This can be customized using the metadata options `logo-position` and `logo-style`.  If `logo-position` has the value `bottom`, the logo image will be placed as the _last_ item on the title slide.  The `logo-style` option allows you to specify Deckset image options to override the default of `left inline`.

You can specify an image file name in the metadata option `titlegraphic` to insert the following code above the text (here for the file name `assets/image1`); this will appear as background image of the title slide:

```
![](assets/image1)
```

The metadata option `titlegraphic-style` allows you to specify image options for the background image (which won’t actually be a background image if you use the `left` or `right` options).

The `logo` and `titlegraphic` options can be used together.  See the Deckset documentation for the possible values of `logo-style` and `titlegraphic-style`.

You can further customize the title slide using the `titleoptions` metadata option.  Key–value pairs specified in a YAML dictionary are inserted as configuration commands.  For example,

``` yaml
titleoptions:
    header: "Frutiger Neue LT Pro, #FFFFFF, text-scale(1.1)"
    background-color: "#23AB2C"
```

would insert the following configuration commands into the Deckset file:

``` markdown
[.background-color: #23AB2C]

[.header: Frutiger Neue LT Pro, #FFFFFF, text-scale(1.1)]
```

See the Deckset documentation for the available commands.

## Alerted text

The `deckset-slides.lua` filter converts spans with the class *alert* to Deckset-style combined emphasis (currently `_**…**_`).  According to the Deckset documentation, “some themes have additional style options for those combinations.”  Thus, depending on the theme, alerted text may or may not be actually highlighted.

::: slide
# Alerted Text

It is the argument of this book that not only are these conflicts still not resolved, but [they remain fundamentally unresolvable]{.alert}.

(Depending on the theme, the passage “they remain fundamentally unresolvable” may or may not be highlighted.)
:::

::: slide
# Alerted Text in a Quotation

> It is the argument of this book that not only are these conflicts still not resolved, but [they remain fundamentally unresolvable]{.alert}.

(Depending on the theme, the passage “they remain fundamentally unresolvable” may or may not be highlighted.)
:::

## Global Configuration Commands as Metadata Options

As already mentioned above, you can specify [global configuration commands for Deckset](https://docs.deckset.com/English.lproj/Customization/01-configuration-commands.html) as metadata options, e.g.,

```
theme: Fira, 3
slidenumbers: true
```

## Per-Slide Commands as Attributes

Instead of using [Deckset’s per-slide commands](https://docs.deckset.com/English.lproj/Customization/01-configuration-commands.html) such as `[.slidenumbers=false]`, you can specify them as attributes of the `slide` block, e.g.:

```
::: {.slide slidenumbers=false footer="A different footer"}
```

::: {.slide slidenumbers=false footer="A different footer"}
This slide has a different footer and no slide number.
:::

This also applies to the custom theming options (see the [Deckset documentation](https://docs.deckset.com/English.lproj/Customization/02-custom-theming.html), for example:

```
::: {.slide background-color=#FF0000}
A slide with a red background
:::
```

::: {.slide background-color=#FF0000}
# A slide with a red background
:::

All of these options are ignored for embedded slides.

## Bibliographic References

With citeproc, you can use bibliographic references on the slides and in the notes.  When generating Deckset slides, add the `deckset-post-citeproc.lua` filter *after* the `--citeproc` option.  The bibliography on the slides will list only those references that appear on slides.  For example, the following quotation from @Klaus1966a is not on a slide, so the reference will not appear in the bibliography:

::: {lang=de}
> Die Maschine ist zwar nur das anorganische Produkt des Menschen, eine Form der Rückwirkung des Menschen auf die anorganische Natur, gleichzeitig ist sie damit aber auch ein Stück seiner umgestalteten Umwelt und insofern ein Bestandteil der menschlichen Welt. Der Mensch paßt sich seiner Umgebung an. Aber er paßt seine Umgebung zugleich auch bewußt seinen menschlichen Bedürfnissen an. Dieses Verhalten unterscheidet den Menschen wesentlich vom Tier, das seine Umwelt nur zufällig und unbewußt umgestaltet. Zwischen Mensch und Maschine besteht ein wechselseitiger Anpassungsprozeß, bei dem der Mensch grundsätzlich und im ganzen gesehen die primäre Rolle spielt; er spielt diese Rolle jedoch nicht in jeder Beziehung. Zwar schafft er die Maschine, um seine eigenen Unzulänglichkeiten im Kampf mit der Natur zu überwinden oder zum Teil auszugleichen, die relativen Unvollkommenheiten der von ihm geschaffenen Mittel muß er aber seinerseits wieder mit spezifisch menschlichen Mitteln kompensieren. Einmal geschaffen, unterwirft sich daher die Maschine, von der technischen Seite her gesehen, in gewisser Hinsicht auch den Menschen.
> [@Klaus1966a, 119]
:::

On the other hand, the references on the following slides will be listed on the bibliography slide:

::: slide
# The Hyperreal

:::: {lang=fr}
> Aujourd’hui l’abstraction n’est plus celle de la carte, du double, du miroir ou du concept. La simulation n’est plus celle d’un territoire, d’un être référentiel, d'une substance. Elle est la génération par les modèles d'un réel sans origine ni réalité : hyperréel.  
> -- @Baudrillard1981 [10]
::::
:::

The list of references is left-aligned and uses an em-dash as bullet to make sure it works even for fancy themes. The bullet can be customized using the `bibliography-bullet` metadata option; `bibliography-bullet` can also be the empty string.  You can also specify the indentation for lists in Deckset; by default, the `deckset-post-citeproc.lua` filter sets it to 12 for the bibliography.  This can by changed using the `bibliography-indent` metadata option.  If you want to format the bibliography exactly like other lists, you need to check the settings for the style in the GUI.

By setting `bibliography-bullet` to an empty string and changing `bibliography-indent` you can, for example, achieve hanging indents (especially interesting if you use a numerical citation style).

The `autoscale` option is set for the bibliography slide, but if there are too many references, it will probably become unreadable.  The bibliography is currently limited to a single slide.

For notes, the bibliography section lists all references that appear either in the notes or in the embedded slides.

::: slide

![left](assets/image1)

# [Geräteentfremdung]{lang=de}

@Klaus1961 coins the term [*Geräteentfremdung*]{lang=de}.
:::

The title for the bibliography can be controlled using the `reference-section-title` metadata option, as usual.

## Controlling Image Attributes on Embedded Slides

Deckset does not support attributes, so the filter strips them off.  This can be used to control the size of images for embedded slides (which are automatically scaled by Deckset).

::: slide
# Image Grids

![inline fill](assets/image2){width=30%}![inline fill](assets/image3){width=30%}  
![inline fill](assets/image1){width=30%}
:::

## Customizing the Rendering of Embedded Slides

When generating LaTeX output, embedded slides are wrapped in an `embed-slide` environment, which is by default defined as a new tcolorbox environment using `\newtcolorbox`.  It can be customized by redefining this environment using `\renewtcolorbox`.

Slide headers are wrapped in a `\slideheader` macro with two arguments, the header level and the content.  This allows the user to customize the appearance by redefining the macro in `header-Includes`.  For example:

````
   header-includes: |
       ```{=latex}
       \renewcommand{\slideheader}[2]{%
       \textsc{%
         \ifcase#1\relax
         \or\Large%
         \or\large%
         \or\bfseries%
         \fi%
         #2}
       }
       ```
````

## Showing and Hiding Content

A slide with the class `presentation` will not appear in the notes:

```
::: {.slide .presentation}
Presentation only
:::
```

The classes `presentation` and `lecturenotes` can also be added to individual images (e.g., decorative backgrounds) and code blocks to prevent their inclusion in the lecture notes or the slides, respectively:

```
::: slide
![](assets/image1){.presentation}

:::: {lang=de}
> Die Philosophen haben die Welt nur verschieden interpretirt; es kommt aber darauf an,
> sie zu verändern.  
-- Karl Marx
::::
:::
```

::: slide
![](assets/image1){.presentation}

:::: {lang=de}
> Die Philosophen haben die Welt nur verschieden interpretirt; es kommt aber darauf an, sie zu verändern.  
-- Karl Marx
::::
:::

If the metadata option `showslides` is false, all slides will be excluded from the notes.

## Dual-Use Presenter Notes

Deckset turns every paragraph starting with a `^` into a presenter note and doesn’t show this text on the slides.  When embedding slides, these notes aren’t output either.  However, sometimes the presenter notes could also serve as “caption” on the lecture notes.

Instead of duplicating the text, once as a presenter note, and once as a paragraph with the `.lecturenotes` class, you can use a _dual-use presenter note_: a paragraph starting with `^^` will appear as presenter note on slides and as a “caption” on lecture notes.  For example:

```
::: slide
Slide content

^ Regular presenter note—doesn’t appear in lecture notes

^^ Dual-use presenter note—rendered as “caption” in lecture notes.
:::
```

is rendered as:

::: slide
Slide content

^ Regular presenter note—doesn’t appear in lecture notes

^^ Dual-use presenter note—rendered as slide “caption” in lecture notes.
:::

# Image and Video Credits

- `image1`: Photo by [Gabriel Garcia Marengo](https://unsplash.com/@gabrielgm?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/lausanne?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText).
  
- `image2`: Photo by [Mark de Jong](https://unsplash.com/@mrmarkdejong?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/lausanne?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

- `image3`: Photo by [Nolan Krattinger](https://unsplash.com/@odes?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/unil?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

- `video1.mp4`: Davidmoerike, [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0), via [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Lausanne-metro2-Ouchy.ogv)

