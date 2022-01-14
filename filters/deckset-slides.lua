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
   
   -- [TODO] logo/background image
   -- table.insert(hblocks, pandoc.RawBlock('markdown', '![](graphics/close_encounters-02.jpg)'))
   table.insert(hblocks, pandoc.RawBlock('markdown', '![left 100% inline](graphics/unilogo_blanc_300dpi.png)'))
   
   table.insert(hblocks, pandoc.Header(1, doc.meta.title))

   if doc.meta.subtitle then
      table.insert(hblocks, pandoc.Header(2, doc.meta.subtitle))
   end

   table.insert(hblocks, pandoc.Header(4, doc.meta.date))

   if doc.meta.author.t == 'MetaInlines' then
      -- Single author name
      table.insert(hblocks, pandoc.Para(doc.meta.author))
   else
      for i, entry in pairs(doc.meta.author) do
         if entry.t == 'MetaInlines' then
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
               aff_str = '(' .. table.concat(aff, '; ') .. ')'
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
                                          ' ',
                                          aff_str,
                                          pandoc.RawInline('markdown', '<br>'),
                                          pandoc.Code(
                                             (pandoc.utils.stringify(eml_str)))
            }))
         end
      end
   end

   -- Regular slides

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
               commands = commands .. string.format('[.%s: %s]\n', key, val)
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

function Image (el)
   -- Remove classes and attributes from images (not supported by Deckset)
   return pandoc.Image(el.caption, el.src)
end

function Span (el)
   -- Replace spans (not supported by Deckset) with their content
   return el.content
end

function SoftBreak (el)
   -- Replace "soft" line breaks (within a paragraph) with explicit
   -- ones.  It seems that this is what the hard_line_breaks extension
   -- is supposed to do, but it dosn't work for me.
   return pandoc.RawInline('markdown', '<br>')
end

function Meta (el)
   -- Set the date in the document’s metadata to the current date, if
   -- a date isn’t already set

   if el.date == nil then
      el.date = os.date("%F")

      return el
   end
end
