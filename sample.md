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
footer: "pandoc-lecturenotes"
slidenumbers: true
subtitle: "Generating lectures and notes from a single document"
showslides: true
---

# Deckset Features

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

Or use double asterisks for an **strong emphasis** style.
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

::: slide
# More Styles

- ~~Strikethrough~~
- Super<sup>script</sup> (Pandoc: Super^script^)
- Sub<sub>script</sub> (Pandoc: Sub~script~)
- `Inline code`
:::

## Quotes

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

::: slide
# Link to External Resources
<a name="link-target"/>

In case you're looking for something, you could use [Google](http://google.com) or [Wikipedia](http://wikipedia.com).

Links will be clickable in exported PDFs as well!
:::

In addition to HTML syntax, we also support (and prefer) an ID attribute on the slide div.  Anchors are exported to Deckset, LaTeX, and ms. 

::: slide
# Links Between Slides

Define an anchor on the slide you want to link to using standard HTML syntax:

`<a name="link-target"/>`

Then you can link to this [slide](#link-target) easily.
:::

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

We support `[.code-highlight: …]` but prefer attributes on the slide div.

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

This currently doesn’t work if each `[.code-highlight: …]` isn’t a paragraph on its own.  Either put each command in its own paragraph or use attributes on the slide div instead (preferred).

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

::: slide
# Emojis

Deckset supports Slack style emojis, e.g.: `:sunny:` `:umbrella:` `:sunflower:` `:cat:` `:smile:`

Deckset supports emojis! :umbrella: :sunflower: :cat: :smile: :thumbsup:

Please refer to this [Emoji Reference Markdown file](http://deckset-assets.s3.amazonaws.com/emoji-reference.md) to see which emoji are supported in Deckset. There are a few favourites that aren’t part of Unicode yet, so we cannot support them.
:::

## Footers and Slide Numbers

To add a persistent footer to each slide of your presentation, insert the following command at the *top* of your file:

```
footer: Your footer goes here
```

To add running slide numbers to each slide of your presentation, insert the following command at the *top* of your file:

```
slidenumbers: true
```

When combining the two commands, please make sure that there are *no empty lines* between the two.

```
footer: Your footer goes here
slidenumbers: true
```

You can use standard text styles such as emphasis in your footer text, just as you would in other places too.

```
footer: Use *emphasis* and ~~other~~ text styles if you like
```

If you want to disable footers or slide numbers on individual slides, you can do so by using per slide commands.

## Footnotes

::: slide
# Footnotes

Footnotes are a breeze, for example:

Most of the time, you should adhere to the APA citation style[^1].

Note that footnote references have to be *unique in the markdown file*. This means, that you can also reference footnotes from any slide, no matter where they are defined.

[^1]: For more details on the citation guidelines of the American Psychological Association check out their [website](https://www.library.cornell.edu/research/citation/apa).

:::

Named references with spaces are not supported by Pandoc, but they are not useful anyway, as we have real citations.

::: slide
# Named References

Instead of just numbers, you can also name your footnote references[^Wiles, 1995].

[^Wiles, 1995]: [Modular elliptic curves and Fermat's Last Theorem](http://math.stanford.edu/~lekheng/flt/wiles.pdf). Annals of Mathematics 141 (3): 443–551.

:::

## Controlling Line Breaks

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

::: slide
# Auto-Scaling

At times you have to fit more content onto one slide than the default font sizes allow for.

Deckset comes with an option to auto-scale paragraph text, lists, and other body content down to fit onto the slide. To enable this behavior put

`autoscale: true`

on the first line of your markdown file.
:::

## Columns

This works in Deckset, but converting this to LaTeX or ms would probably be a major effort.

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
![](graphics/image1.jpg)
:::

Fit Background Image

::: slide
![fit](graphics/image1.jpg)
:::

Multiple Background Images.  Deckset doesn’t require that each image is a separate paragraph, but this is the same issue as with multiple per slide commands—so, for Pandoc, insert a newline between them.

Also, this doesn’t easily convert to LaTeX or ms—this is essentially the same problem as with multiple columns.

::: slide
![](graphics/image1.jpg)

![](graphics/image2.jpg)

![](graphics/image3.jpg)
:::

## Text on Images

None of the following features are converted to LaTeX or ms.

::: slide
![](graphics/image1.jpg)

# Text on Images

Setting text on images applies a filter to the image to make the text more readable.
:::

::: slide
![original](graphics/image1.jpg)

# Disable Filter
:::

::: slide
![left filtered](graphics/image1.jpg)

# Force Apply Filter

Use the `filtered` keyword to apply the theme's filter to an image that isn't filtered by default.
:::

::: slide
![original 250%](graphics/image1.jpg)

# Zoom In
:::

This works in LaTeX.

::: slide
![right fit](graphics/image1.jpg)

# Split Slides

Combine `left` or `right` with the `fit` keyword or a percentage to adjust the image scaling.
:::

## Inline Images

Combine Text and Images

::: slide
# Combine Text and Images

![inline](graphics/image1.jpg)
:::

::: slide
# Fill the Slide

![inline fill](graphics/image1.jpg)
:::

Custom scaling could perhaps be converted to LaTeX and ms, but it’s not clear to me what the scaling refers to.  It’s currently not handled.

::: slide
# Custom Scaling

![inline 50%](graphics/image1.jpg)
:::

Image grids would be very hard to convert to LaTeX and ms; we would first need to identify arrangements that are treated as image grids by Deckset and then work out an equivalent arrangement.  This is currently not handled.

::: slide
# Image Grids

![inline fill](graphics/image2.jpg)![inline fill](graphics/image3.jpg)  
![inline fill](graphics/image1.jpg)
:::

One problem, however, is that not all images may fit onto the page.  A workaround for LaTeX output is to add a Pandoc size attribute, which is removed by the Deckset filter.

## Videos

Audio, video and all images with Web links are replaced with a placeholder in LaTeX and ms output.

::: slide
![](media/video1.mp4)
:::

::: slide
# Inline Videos

![inline](media/video1.mp4)
:::

::: slide
# YouTube Embeds!

![](https://youtu.be/v3M0SJ2sJqg)

You can also use URL parameters like `?t=30s` to specify a start time for the clip.
:::

::: slide
![left](media/video1.mp4)

# Video Layout Control

Use the same layout modifiers as with images to control the positioning of videos.

- `left` and `right`
- `fit` and `fill`
- Percentage sizing, e.g. `50%`
- `hide` to hide the video. Audio will play regardless.
:::

::: slide
![right autoplay mute](media/video1.mp4)

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

![](~/lib/audio/pacman.au)

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

Using presenter notes

Deckset turns every paragraph that starts with a `^` into presenter notes and doesn’t show this text on the slides.

You’ll see these notes on the presenter display (with two screens connected) or by using the rehearsal mode.

To preview your presenter notes in the main application window, you can turn them on by selecting `Toggle Presenter Notes` from the `View` menu.

To start another presenter note paragraph, prefix it with a caret again. Deckset will automatically scale the notes down to fit onto the presenter display in case you have a lot of text.

Example:

::: slide
# My slide title

^ This is a presenter note.
:::

### Customize the display of presenter notes

To customize the style of presenter notes, in both Presenter and Rehearsal modes and in exported documents, you may use the `presenter-not command like so:

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

::: slide
# Image Credits

`image1.jpg`: Photo by [Gabriel Garcia Marengo](https://unsplash.com/@gabrielgm?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/lausanne?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText).
  
`image2.jpg`: Photo by [Mark de Jong](https://unsplash.com/@mrmarkdejong?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/lausanne?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

`image3.jpg`: Photo by [Nolan Krattinger](https://unsplash.com/@odes?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/unil?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

`video1.mp4`: Davidmoerike, [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0), via [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Lausanne-metro2-Ouchy.ogv)
:::