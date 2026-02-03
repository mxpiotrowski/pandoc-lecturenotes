local text = require 'text'
local List = require 'pandoc.List'

local showslides = true

function join (sep, list)
   local result = ''
   
   for i, str in pairs(list)
   do
      result = result .. str .. (i < #list and sep or '')
   end

   return result
end

function slice (list, first, last)
   -- table.unpack() doesn't seem to work correctly on Pandoc lists
   result = pandoc.List()

   if not last then
      last = #list
   end
   
   for i, e in pairs(list) do
      if i >= first and i <= last then
         result:insert(e)
      end
   end

   return result
end

function add_raw_block (target, format, code)
   table.insert(target, pandoc.RawBlock(format, code))
end

function format_slides (elem)
   local result = {}

   -- Don't include slides with the .presentation class, but
   -- increment the slide counter, so that slide numbers match.

   if elem.classes:includes('presentation', 1) then
      if FORMAT:match 'latex' then
         add_raw_block(result, FORMAT, '\\addtocounter{slidectr}{1}')
      elseif FORMAT:match 'ms' then
         add_raw_block(result, FORMAT, '.nr slidectr +1')
      elseif FORMAT:match 'typst' then
         add_raw_block(result, FORMAT, '#counter(figure.where(kind: "fslide")).step()')
      end
      
      return result
   end

   -- Render slides not marked at presentation-only.
   
   if elem.classes:includes('slide') and showslides == true then

      if FORMAT:match 'latex' then -- LaTeX
         add_raw_block(result, FORMAT, '\\addtocounter{slidectr}{1}')
         add_raw_block(result, FORMAT, '\\begin{embed-slide}{Slide~\\theslidectr}')

         -- Output link anchor if the slide has an ID attribute
         if elem.identifier ~= '' then
            add_raw_block(result, FORMAT,
                          '\\hypertarget{' .. elem.identifier .. '}{}')
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

            elseif el.t == "Div" and el.classes:includes('notes', 1) then
               ; -- Don't output Pandoc-native presenter notes

            elseif el.t == "Div" and el.classes:includes('columns', 1) then
               -- Pandoc-native columns

               local col_formats = {}
               local format_column = function (elem)
                  if elem.classes:includes('column') then
                     table.insert(col_formats, elem.attributes['width'])
                     return elem
                  end

                  return nil
               end

               local columns = el.c:walk({ Div = format_column })

               -- print("◊", #columns) -- [DEBUG]
            
               table.insert(result,
                            pandoc.RawBlock(FORMAT, '\\begin{tcbraster}[raster columns=' .. #col_formats .. ']'))
            
               for _, block in pairs(columns) do
                  -- [HACK] There must be no newline between the
                  -- tcolorboxes, but it's not possible to output
                  -- RawBlocks without newlines.  We therefore check
                  -- it the previous RawBlock is \end{tcolorbox} and
                  -- then add the \begin{tcolorbox} to the same
                  -- RawBlock.
                  if result[#result].t == 'RawBlock' and result[#result].text:match('^\\end{tcolorbox}') then
                     result[#result].text =  result[#result].text .. '\\begin{tcolorbox}'
                  else
                     table.insert(result, pandoc.RawBlock(FORMAT, '\\begin{tcolorbox}'))
                  end
                  table.insert(result, block)
                  table.insert(result, pandoc.RawBlock(FORMAT, '\\end{tcolorbox}'))
               end

               table.insert(result, pandoc.RawBlock(FORMAT, '\\end{tcbraster}'))

            elseif (el.t == "Para" and
                    string.match(pandoc.utils.stringify(el), '^%^ ')) then
               ; -- Don't output presenter notes
            elseif (el.t == "Para"
                    and #el.c > 0 -- empty paras can, e.g., be caused by presentation-only images
                    and el.c[1].t == "Superscript" and #el.c[1].c == 0) then
               -- "Dual-use" presenter notes
               add_raw_block(result, FORMAT, '\\tcbline')
               table.insert(result, pandoc.Para(slice(el.content, 3)))
            elseif (el.t == "Para" and string.match(pandoc.utils.stringify(el), '^. . .%s*$')) then
               ; -- Don't output Pandoc native pauses
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
            elseif (el.t == "Figure") then
               table.insert(result, el.c[1])
            else
               table.insert(result, el)
            end
         end

         add_raw_block(result, FORMAT, '\\end{embed-slide}')


      elseif FORMAT:match 'ms' then -- troff ms macros
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
            elseif el.t == "Div" and el.classes:includes('notes', 1) then
               ; -- Don't output Pandoc-native presenter notes
            elseif (el.t == "Para" and
                    string.match(pandoc.utils.stringify(el), '^%^ ')) then
               ; -- Don't output presenter notes
            elseif (el.t == "Para"
                    and #el.c > 0 -- empty paras can, e.g., be caused by presentation-only images
                    and el.c[1].t == "Superscript" and #el.c[1].c == 0) then
               -- "Dual-use" presenter notes
               table.insert(result, pandoc.HorizontalRule())
               table.insert(result, pandoc.Para(slice(el.content, 3)))
            elseif (el.t == "Para" and string.match(pandoc.utils.stringify(el), '^. . .%s*$')) then
               ; -- Don't output Pandoc native pauses
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
                  add_raw_block(result, FORMAT, '.pdfhref M "' .. target .. '"')
               end
            elseif (el.t == "Para" and #el.c == 1 and el.c[1].t == "Image") then
               -- el.c[1].title = ''
               -- el.c[1].caption = ''
               table.insert(result, el)
            elseif (el.t == "Figure") then
               table.insert(result, el.c[1])
            else
               table.insert(result, el)
            end
         end
         
         add_raw_block(result, FORMAT, '.LP\n.B2')
      elseif FORMAT:match 'html' then -- HTML: Work in progress
         -- [TODO] For HTML we could probably mostly keep the Pandoc
         -- AST elements and only make some changes where necessary
         add_raw_block(result, FORMAT, '<article class="embed-slide">')
         add_raw_block(result, FORMAT, '<header>')
         add_raw_block(result, FORMAT, '<p>Slide #</p>')
         add_raw_block(result, FORMAT, '</header>')

         add_raw_block(result, FORMAT, '<section class="slide">')
         
         for i, el in pairs(elem.content) do
            if el.t == "Header" then
               -- [fit] is a Deckset command
               if el.content[1] == pandoc.Str('[fit]') then
                  table.remove(el.content, 1)
               end

               -- Delete leading space
               if el.content[1].t == "Space" then
                  table.remove(el.content, 1)
               end

               table.insert(result, el)
            elseif (el.t == "Para" and
                    string.match(pandoc.utils.stringify(el), '^%^ ')) then
               ; -- Don't output presenter notes
            elseif (el.t == "Para"
                    and #el.c > 0 -- empty paras can, e.g., be caused by presentation-only images
                    and el.c[1].t == "Superscript" and #el.c[1].c == 0) then
               -- "Dual-use" presenter notes
               table.insert(result, pandoc.HorizontalRule())
               table.insert(result, pandoc.Para(slice(el.content, 3)))
            elseif (el.t == "Para" and
                    string.match(pandoc.utils.stringify(el), '^%[%.column]%s*$')) then
               -- Handle the Deckset [.column] command
               table.insert(result, pandoc.HorizontalRule())
            elseif (el.t == "Para" and
                    string.match(pandoc.utils.stringify(el), '^%[%.[-%a]+')) then
               ; -- Don't output Deckset per-slide commands
            elseif (el.t == "Para" and #el.c == 1 and el.c[1].t == "Image") then
               if el.c[1].caption then
                  if string.match(pandoc.utils.stringify(el.c[1].caption), 'right') then
                     el.c[1].classes = {'ds-right'}
                  elseif string.match(pandoc.utils.stringify(el.c[1].caption), 'left') then
                     el.c[1].classes = {'ds-left'}
                  elseif string.match(pandoc.utils.stringify(el.c[1].caption), 'inline') then
                     el.c[1].classes = {'ds-inline'}
                  end
               end
               
               table.insert(result, el)
            else
               table.insert(result, el)

            end
         end

         -- table.insert(result, elem)
         add_raw_block(result, FORMAT, '</section>')
         add_raw_block(result, FORMAT, '</article>')

         -- table.insert(result, elem)

      elseif FORMAT:match 'typst' then -- Typst: Work in progress
         local result = {}
         local split = {}
         local colbreaks = 0
         local caption = nil

         -- Check for split slide; remove image from list of blocks
            
         for i, block in ipairs(elem.content) do
            if (block.t == "Para" and #block.c == 1 and block.c[1].t == 'Image') then
               local opt_str = pandoc.utils.stringify(block.c[1].caption)
               local options = pandoc.List({})
               for str in opt_str:gmatch("([^%s]+)") do table.insert(options, str) end
           
               if options:includes('left') then
                  split['left'] = table.remove(elem.content, i)
               end

               if options:includes('right') then
                  split['right'] = table.remove(elem.content, i)
               end
            end
         end

         -- Iterate over the list of blocks
   
         for _, block in pairs(elem.content) do -- [TODO] Handling of special constructs not yet complete!
            if block.t == "Header" then
               -- [fit] is a Deckset command
               if block.content[1] == pandoc.Str('[fit]') then
                  table.remove(block.content, 1)
               end

               -- Delete leading space
               if block.content[1].t == "Space" then
                  table.remove(block.content, 1)
               end

               table.insert(result, block)

            elseif block.t == "Div" and block.classes:includes('notes', 1) then
               ; -- Don't output Pandoc-native presenter notes

            elseif block.t == "Div" and block.classes:includes('columns', 1) then
               -- Pandoc-native columns

               local col_formats = {}
               local format_column = function (elem)
                  if elem.classes:includes('column') then
                     table.insert(col_formats, elem.attributes['width'])
                     -- elem.attributes['typst:fill'] = 'luma(250)'
                     elem.attributes['typst:width'] = '100%'
                     return elem
                  end

                  return nil
               end

               local columns = block.c:walk({ Div = format_column })

               -- print("◊", #columns) -- [DEBUG]
            
               table.insert(result,
                            pandoc.RawBlock(FORMAT,
                                            '#grid(columns: (' .. join(',', col_formats)
                                            .. '), inset: 0.25em, gutter: 0.25em, stroke: 0.5pt + gray, '))
            
               for _, block in pairs(columns) do
                  table.insert(result, pandoc.RawBlock(FORMAT, '['))
                  table.insert(result, block)
                  table.insert(result, pandoc.RawBlock(FORMAT, '],'))
               end

               table.insert(result, pandoc.RawBlock(FORMAT, ')'))
            
            elseif block.t == "Para" then
               local str_content = pandoc.utils.stringify(block.c)

               if str_content:match('^%^ ') then
                  ; -- Don't output presenter notes

               elseif (#block.c > 0 -- empty paras can, e.g., be caused by presentation-only images
                       and block.c[1].t == "Superscript" and #block.c[1].c == 0) then
                  -- "Dual-use" presenter notes

                  -- [TODO] It may be better to store the notes as
                  -- Pandoc objects and only render them when we
                  -- insert them into the #fslide(caption: [...])
                  local tmpdoc = pandoc.Pandoc( { pandoc.Para(slice(block.content, 3)) } )
                  caption = pandoc.write(tmpdoc, 'typst')

               elseif str_content:match('^. . .%s*$') then
                  ; -- Don't output Pandoc-native pauses
                  
               elseif str_content:match('^%[%.column]%s*$') then
                  -- Deckset [.column] command
                  
                  if colbreaks == 0 then -- start of the first column
                     add_raw_block(result, FORMAT, "// START COLUMNS")
                  else
                     add_raw_block(result, FORMAT, "#colbreak()")
                  end
            
                  colbreaks = colbreaks + 1
               elseif str_content:match('^%[%.[-%a]+') then
                  ; -- Don't output Deckset per-slide commands
               else
                  table.insert(result, block)
               end
            else
               table.insert(result, block)
            end
         end

         -- Finish the slide
      
         if split['left'] then
            -- Insert setup and image at the beginning of result
            for i, stuff in ipairs { pandoc.RawBlock(FORMAT, '#columns(2, gutter: 2em)['),
                                     split['left'],
                                     pandoc.RawBlock(FORMAT, '#colbreak()') } do
               table.insert(result, i, stuff)
            end
            
            add_raw_block(result, FORMAT, "]") -- close #columns()
         elseif split['right'] then
            -- Insert setup at the beginning…
            table.insert(result, 1, pandoc.RawBlock(FORMAT, '#columns(2, gutter: 2em)['))
            -- … and image at the end of result
            add_raw_block(result, FORMAT, '#colbreak()')
            table.insert(result, split['right'])
            
            add_raw_block(result, FORMAT, "]") -- close #columns()
         end

         if colbreaks > 0 then
            for i, block in ipairs(result) do
               if block.t == 'RawBlock' and block.text == '// START COLUMNS' then
                  result[i] = pandoc.RawBlock(FORMAT, '#columns(' .. colbreaks .. ', gutter: 2em)[')
               end
            end

            add_raw_block(result, FORMAT, "]") -- close #columns()
         end

         -- start slide
         table.insert(result, 1,
                      pandoc.RawBlock(FORMAT, '#fslide(caption: '
                                      .. (caption
                                          and ('[' .. caption .. ']')
                                          or 'none') .. ')['))
         
         add_raw_block(result, FORMAT, ']') -- end slide

         if elem.identifier ~= '' then
            add_raw_block(result, FORMAT, '<' .. elem.identifier .. '>')
         end

         return result
      end
      
      -- =====
      
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
      -- Include the tcolorbox package (the “skins” library is required
      -- for \tcbline -- <https://tex.stackexchange.com/questions/303416/>)
      -- Define a counter for slides

      setup_code = [[
\usepackage[skins, raster]{tcolorbox}
\newtcolorbox{embed-slide}[2][]{%
  colframe=orange, colback=orange!8!white,
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
   elseif FORMAT:match 'typst' then
      setup_code = [[
#let fslide(body, fill: luma(230), label: "Slide", caption: none) = {
    let slideheader(it) = block(fill: orange, inset: .25em, height: 1.5em, radius: .25em)[
        #align(horizon)[
            *#label #context counter(figure.where(kind: "fslide")).display()*
        ]
    ]

    figure(kind: "fslide", caption: caption, supplement: [Slide],
           rect(
               width: 100%,
               fill: fill,
               inset: 0mm,
               radius: .25em,
               [#set align(left);
                #set heading(outlined: false, numbering: none) // Don’t list slide headers in PDF TOC

                #slideheader[];
                #block(above: 0mm, inset: 1em, body)],
    ))
}
]]
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
         elseif FORMAT:match 'typst' then
            return {
               pandoc.RawInline('typst', '⚠ ' .. replacement .. '\n') -- [TODO]
            }
         end
      end
   end
end

function handle_codeblocks (el)
   if el.classes:includes('presentation')  then
      return {}
   end

   return nil
end

function handle_tags (el)
   if el.format == 'html' and el.text == '<br>' then
      return pandoc.LineBreak()
   end
end

function foobar (el)
   print("foobar: ", el.t)
   if el.classes:includes('column') then
      --return pandoc.List({pandoc.RawBlock(FORMAT, '#colbreak()') , el.c[1] })
      return pandoc.Para('Foobar ' .. el.t .. '/' .. el.classes[1])
   else
      return nil
   end
end

return {
   { Meta  = add_setup_code },
   { Image = hide_unsupported_media },
   { CodeBlock = handle_codeblocks },
   { Div   = format_slides },
   { RawInline = handle_tags }
}
