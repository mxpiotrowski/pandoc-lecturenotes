function Pandoc(doc)
   local hblocks = {}

   -- Insert "global configuration commands" (see
   -- https://www.deckset.com/help/tutorials/using-configuration-commands.html)
   ds_commands = pandoc.List({"autoscale", "build-lists", "footer",
                              "slide-dividers", "slidenumbers",
                              "slide-transition", "theme"})
   ds_global = pandoc.RawBlock("markdown", "")
   
   for key, val in pairs(doc.meta) do
      if ds_commands:includes(key, 1) then
         ds_global.text = ds_global.text .. key .. ": " ..
            pandoc.utils.stringify(val) .. "\n"
      end
   end

   table.insert(hblocks, ds_global)

   -- Create title slide
   table.insert(hblocks, pandoc.RawBlock('markdown',
                                         '[.hide-footer]\n[.slidenumbers: false]\n[.slidecount: false]'))

   -- Per-slide customization for the title slide
   if doc.meta.titleoptions then
      for key, val in pairs(doc.meta.titleoptions) do
         table.insert(hblocks, pandoc.RawBlock('markdown', '[.' .. key .. ': ' ..
                                               pandoc.utils.stringify(val) .. ']'))
      end
   end
   
   -- Logo/background image
   if doc.meta.titlegraphic then
      table.insert(hblocks, pandoc.Para({}))
      table.insert(hblocks, pandoc.Image({},
                      pandoc.utils.stringify(doc.meta.titlegraphic)))
   end
   
   if doc.meta.logo then
      table.insert(hblocks, pandoc.Image({pandoc.Str('left fit inline')},
                      pandoc.utils.stringify(doc.meta.logo)))
   end

   if doc.meta.title then
      table.insert(hblocks, pandoc.Header(1, doc.meta.title))
   end
      
   if doc.meta.subtitle then
      table.insert(hblocks, pandoc.Header(2, doc.meta.subtitle))
   end

   if doc.meta.date then
      table.insert(hblocks, pandoc.Header(4, doc.meta.date))
   end

   if doc.meta.author then
      if pandoc.utils.type(doc.meta.author) == 'Inlines' then

         -- Single author name
         table.insert(hblocks, pandoc.Para(doc.meta.author))
      else
         for i, entry in pairs(doc.meta.author) do
            if pandoc.utils.type(entry) == 'Inlines' then
               --  Simple list of author names
               table.insert(hblocks, pandoc.Header(4, entry))
            else
               --[[ Structured author information as produced by the
                  scholarly-metadata filter
                  <https://github.com/pandoc/lua-filters/tree/master/scholarly-metadata>

                  The complexity is mind-boggling, or probably I'm too dumb.

                  We try to handle zero or more affiliations and zero or
                  more e-mail addresses per author.  ]]--

               -- Affiliations
               local aff = {}
               local aff_str = ''
               
               for a, b in pairs(entry.institute) do
                  table.insert(aff,
                               pandoc.utils.stringify(
                                  doc.meta.institute[tonumber(b)].name))
               end

               if #aff > 0 then
                  aff_str = table.concat(aff, '; ')
               end

               if #aff_str > 0 then
                  aff_str= pandoc.Emph {aff_str}
               end
               
               -- E-mail addresses
               local eml = {}
               local eml_str = ' '

               if entry.email then
                  for a, b in pairs(entry.email) do
                     table.insert(eml, pandoc.utils.stringify(b))
                  end

                  eml_str = table.concat(eml, '; ')
               end
               
               table.insert(hblocks,
                            pandoc.Header(4,
                                          {
                                             pandoc.utils.stringify(entry.name),
                                             pandoc.RawInline('markdown', '<br>'),
                                             (aff_str.content and aff_str or ""),
                                             (aff_str.content and pandoc.RawInline('markdown', '<br>') or ""),
                                             pandoc.Code(
                                                (pandoc.utils.stringify(eml_str)))
                                          }
                            )
               )
            end
         end
      end
   end

   -- Regular slides

   local ds_per_slide = pandoc.List({
         "autoscale",
         "background-color",
         "build-lists",
         "code",
         "code-highlight",
         "footer",
         "hide-footer",
         "footer-style",
         "footnote-separator",
         "formula",
         "header",
         "header-emphasis",
         "header-strong",
         "list",
         "quote",
         "quote-author",
         "slide-transition",
         "slidecount",
         "slidenumber-style",
         "slidenumbers",
         "table",
         "table-separator",
         "text",
         "text-emphasis",
         "text-strong",
   })
   
   for i, el in pairs(doc.blocks) do
      if (el.t == "Div" and el.classes:includes("slide")) then
         table.insert(hblocks, pandoc.HorizontalRule())

         -- Insert link anchor if slide has an ID
         if el.identifier ~= '' then
            table.insert(hblocks,
                         pandoc.RawBlock('markdown', '<a name="'
                                         .. el.identifier .. '"/>'))
         end
         
         -- Per-slide configuration commands (specified as attributes
         -- to the slide div)
         if #el.attributes > 0 then
            local commands = ""
            
            for key, val in pairs(el.attributes) do
               if ds_per_slide:includes(key, 1) then
                  commands = commands .. string.format('[.%s: %s]\n', key, val)
               end
            end

            table.insert(hblocks, pandoc.RawBlock('markdown', commands))
         end

         -- table.insert(hblocks, el)
         for j, e in pairs(el.content) do

            -- Per-slide configuration commands (specified inline)

            -- TODO: Deckset only requires that each per slide command
            -- is on its own *line*, it doesn't have to be surrounded
            -- by newlines.  In this case, Pandoc considers these to
            -- be all in one paragraph, and the output will be incorrect.
            local str = pandoc.utils.stringify(e)

            if (e.t == "Para" and str:match('^%[%.[-%a]+')) then
               str=str:gsub('%[%.', '\n[.')

               table.insert(hblocks, pandoc.RawBlock('markdown', str .. '\n'))
            else
               table.insert(hblocks, e)
            end
         end
      end
   end
   
   return pandoc.Pandoc(hblocks, doc.meta)
end

function Header (el)
   -- [fit] is a Deckset command
   if el.content[1] == pandoc.Str('[fit]') then
      el.content[1] = pandoc.RawInline('markdown', '[fit]')
   end
   
   -- Remove classes and attributes from headers (not supported by Deckset)
   return pandoc.Header(el.level, el.content)
end

function Figure (el)
   return el.content[1]
end

function Image (el)
   if el.classes:includes('lecturenotes')  then
      -- Exclude images with the .lecturenotes class.
      return {}
   else
      -- Remove classes and attributes from images (not supported by Deckset)
      return pandoc.Image(el.caption, el.src)
   end
end

function Div (el)
   -- Exclude divs with the .lecturenotes class.
   if el.classes:includes("lecturenotes") then
      return {}
   end

   -- Remove all divs that are not slides
   if not el.classes:includes("slide") then
      return el.content
   end
end

function CodeBlock (el)
   -- Workaround: highlight.js (used by Deckset,
   -- https://github.com/highlightjs/highlight.js/blob/main/SUPPORTED_LANGUAGES.md)
   -- currently doesn't has support for PostScript.
   if el.classes[1] == 'postscript' then
      el.classes[1] = 'txt'
   end
   return el
end

function Math (el)
   -- Deckset uses $$…$$ for both inline and display math.

   -- [TODO] This is a good example why a custom writer may be
   -- cleaner: it works, but potential later filters will no longer
   -- have access to InlineMath elements.
   if el.mathtype == 'InlineMath' then
      return pandoc.RawInline('markdown', '$$' .. el.text .. '$$')
   end
end

function Span (el)
   if el.classes:includes("alert") then
      -- Replace spans with the "alert" class (think Beamer) with
      -- Deckset-style "combined emphasis" markup (which may or may not be
      -- different from regular bold or italics).
      table.insert(el.content, 1, pandoc.RawInline('markdown', '_**'))
      table.insert(el.content, pandoc.RawInline('markdown', '**_'))
      return el.content
      
   else
      -- Otherwise, replace spans (not supported by Deckset) with their content
      return el.content
   end
end

function SoftBreak (el)
   return pandoc.LineBreak()
end

function Meta (el)
   -- Set the date in the document’s metadata to the current date, if
   -- a date isn’t already set

   if el.date == nil then
      el.date = os.date("%F")

      return el
   end
end
