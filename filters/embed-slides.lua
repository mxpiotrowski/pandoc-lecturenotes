local text = require 'text'
local List = require 'pandoc.List'

local showslides = true

function add_raw_block (target, format, code)
   table.insert(target, pandoc.RawBlock(format, code))
end

function format_slides (elem)
   local result = {}

   if elem.classes:includes('presentation', 1) then
      -- Don't include slides with the .presentation class, but
      -- increment the slide counter, so that slide numbers match.
      if FORMAT:match 'latex' then
         add_raw_block(result, FORMAT, '\\addtocounter{slidectr}{1}')
      elseif FORMAT:match 'ms' then
         add_raw_block(result, FORMAT, '.nr slidectr +1')
      end
      
      return result
   end
   
   if elem.classes:includes('slide') and showslides == true then
      if FORMAT:match 'latex' then
         add_raw_block(result, FORMAT, '\\addtocounter{slidectr}{1}')
         add_raw_block(result, FORMAT, '\\begin{embed-slide}{Slide~\\theslidectr}')
         -- Output link anchor if the slide has an ID attribute
         if elem.identifier ~= '' then
            add_raw_block(result, FORMAT, '\\hypertarget{'
                          .. elem.identifier .. '}{}')
         end
         
         for i, el in pairs(elem.content) do
            if el.t == "Header" then
               -- table.insert(result, pandoc.Para(pandoc.Strong(el.content)))

               -- [fit] is a Deckset command
               if el.content[1] == pandoc.Str('[fit]') then
                  table.remove(el.content, 1)
               end

               -- Delete leading space
               if el.content[1].t == "Space" then
                  table.remove(el.content, 1)
               end

               -- Wrap the header content in a LaTeX command, which
               -- can be customized if desired.
               table.insert(el.content, 1,
                            pandoc.RawInline(FORMAT, '\\slideheader{'
                                             .. el.level .. '}{'
               ))
               table.insert(el.content, pandoc.RawInline(FORMAT, '}'))
               table.insert(result, pandoc.Para(el.content))

            elseif (el.t == "Para" and
                    string.match(pandoc.utils.stringify(el), '^%^ ')) then
               ; -- Don't output presenter notes
            elseif (el.t == "Para" and
                    string.match(pandoc.utils.stringify(el), '^%[%.column]%s*$')) then
               -- Handle the Deckset [.column] command
               table.insert(result, pandoc.HorizontalRule())
            elseif (el.t == "Para" and
                    string.match(pandoc.utils.stringify(el), '^%[%.[-%a]+')) then
               ; -- Don't output Deckset per-slide commands
            elseif (el.t == "Para" and #el.c == 1 and el.c[1].t == "RawInline"
                    and el.c[1].format == 'html') then
               -- Deckset uses HTML syntax for defining anchors.  We
               -- support this, but prefer an ID attribute on the
               -- slide div
               
               local target = el.c[1].text:match('^<a name="(.+)"/>')

               if target then
                  add_raw_block(result, FORMAT, '\\hypertarget{' .. target .. '}{}')
               end
            elseif (el.t == "Para" and #el.c == 1 and el.c[1].t == "Image") then
               -- With the implicit_figures extension active, an image
               -- with nonempty alt text, occurring by itself in a
               -- paragraph, will be rendered as a figure with a
               -- caption.  The image’s alt text will be used as the
               -- caption.  (↗ <https://pandoc.org/MANUAL.html#extension-implicit_figures>)
               
               -- This is not a good idea inside slides, because (1)
               -- the alt text is only intended for Deckset (which
               -- uses it for options) and (2) the resulting LaTeX
               -- fails to compile due to having a figure (= float)
               -- inside the tcolorbox (and even if one used a
               -- different layout, it wouldn't make sense for slides
               -- to contain floats).

               -- Experimental: put an image with the "right" option
               -- in the "lower" part of the tcolorbox and set the
               -- "sidebyside" option on the slide.  The image should
               -- be the last element on the slide, otherwise the rest
               -- of the content will also end up on the right side.
               -- This is a bit hackish as it relies on the fact that
               -- the \begin{embed-slide} is the second item in the
               -- result table.
               if el.c[1].caption and
                  string.match(pandoc.utils.stringify(el.c[1].caption), 'right') then
                  add_raw_block(result, FORMAT, '\\tcblower')
                  result[2] = pandoc.RawBlock(FORMAT, '\\begin{embed-slide}[sidebyside, sidebyside align=top seam]{Slide~\\theslidectr}')
               end

               -- Unset the title to prevent the creation of a figure
               -- and insert the element.
               el.c[1].title = ''
               table.insert(result, el)

               -- The same as above, but for images with the "left"
               -- option.  In this case, the image should be the first
               -- element on the slide.
               if el.c[1].caption
                  and string.match(pandoc.utils.stringify(el.c[1].caption), 'left') then
                  add_raw_block(result, FORMAT, '\\tcblower')
                  result[2] = pandoc.RawBlock(FORMAT, '\\begin{embed-slide}[sidebyside, sidebyside align=top seam]{Slide~\\theslidectr}')
               end
            else
               table.insert(result, el)
            end
         end

         add_raw_block(result, FORMAT, '\\end{embed-slide}')
      elseif FORMAT:match 'ms' then
         add_raw_block(result, FORMAT, '.nr slidectr +1')
         add_raw_block(result, FORMAT, '.LP\n.B1\n.B \\s-4'
                       .. text.upper(elem.classes[1]) .. '\\ \\n[slidectr]')

         -- Output link anchor if the slide has an ID attribute
         if elem.identifier ~= '' then
            add_raw_block(result, FORMAT, '.pdfhref M "'
                          .. elem.identifier .. '"')
         end
         
         for i, el in pairs(elem.content) do
            if el.t == "Header" then
               table.insert(result, pandoc.Para(pandoc.Strong(el.content)))
            elseif (el.t == "Para" and #el.c == 1 and el.c[1].t == "RawInline"
                    and el.c[1].format == 'html') then
               -- Deckset uses HTML syntax for defining anchors.  We
               -- support this, but prefer an ID attribute on the
               -- slide div
               
               local target = el.c[1].text:match('^<a name="(.+)"/>')

               if target then
                  add_raw_block(result, FORMAT, '.pdfhref M "' .. target .. '"')
               end
            else
               table.insert(result, el)
            end
         end
         
         add_raw_block(result, FORMAT, '.LP\n.B2')
      end
      
      return result
   elseif elem.classes:includes('slide') then
      return {}  -- showslides == false → suppress slide
   else
      return nil -- leave other Divs alone
   end
end

function get_vars (meta)
   if meta.showslides == false then
      showslides = false
  end
end

--- Add format-specific setup code to header-includes

function add_setup_code (meta)
   get_vars(meta)
   
   if not meta['header-includes'] then
      meta['header-includes'] = pandoc.MetaBlocks({})
   end

   local header_includes = { meta['header-includes'] }
   local setup_code = ''

   if FORMAT:match 'latex' then
      -- Include the tcolorbox package
      -- Define a counter for slides

      setup_code = [[
\usepackage{tcolorbox}
\newtcolorbox{embed-slide}[2][]{%
  colframe=Apricot, colback=Apricot!8!white,
  fonttitle=\footnotesize\sffamily\bfseries,
  valign=top, title={#2}, #1}
\newcounter{slidectr}\setcounter{slidectr}{1}
\newcommand{\slideheader}[2]{%
  \raggedright\textsf{%
    \ifcase#1\relax%
    \or\Large%
    \or\large%
    \or\bfseries%
    \fi%
    #2}%
  \vspace{\baselineskip}}
      ]]

      setup_code = '% Added by ' .. PANDOC_SCRIPT_FILE .. '\n' .. setup_code
      .. '\n% End'
   elseif FORMAT:match 'ms' then
      -- Define a counter for slides

      setup_code = '.nr slidectr 1'
      setup_code = '.\\" ' .. string.rep('*', 63) .. '\n' ..
      '.\\" Added by ' .. PANDOC_SCRIPT_FILE .. '\n' .. setup_code
   end

   List.insert(header_includes, 1, pandoc.RawBlock(FORMAT, setup_code))
   
   meta['header-includes'] = header_includes
   return meta
end

function hide_unsupported_media (el)
   local patterns = {'^http', '%.mov$', '%.mp4$', '%.au$', '%.wav$',
                     '%.mp3$', '%.m4a$', '%.ogg$', '%.flac$',}
   local replacement = 'Audio, video, or Web resource'

   if el.classes:includes('presentation')  then
      return {}
   end
   
   for _, pat in pairs(patterns) do
      if el.src:match(pat) then
         -- Shorten filename if necessary
         local filename =
            (el.src:len() > 30) and (el.src:sub(1, 29) .. '…') or el.src
         
         if FORMAT:match 'latex' then
            return {
               pandoc.RawInline('latex',
                                '\\tcbox{' .. replacement .. ': \\href{'),
               pandoc.Str(el.src),
               pandoc.RawInline('latex', '}{'),
               pandoc.Str(filename),
               pandoc.RawInline('latex', '}}\n')
            }
         elseif FORMAT:match 'ms' then
            return {
               pandoc.RawInline(FORMAT, '.BX "' .. replacement .. ': '),
               pandoc.Str(filename),
               pandoc.RawInline(FORMAT, '\n')
            }
         end
      end
   end
end

function handle_tags (el)
   if el.format == 'html' and el.text == '<br>' then
      return pandoc.LineBreak()
   end
end

      

return {
   { Meta  = add_setup_code },
   { Image = hide_unsupported_media },
   { Div   = format_slides },
   {RawInline = handle_tags}
}
