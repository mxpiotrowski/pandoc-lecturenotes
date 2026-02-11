csl_fields = pandoc.List({"abstract", "accessed", "annote", "archive", "archive_collection", "archive_location", "archive-place", "author", "authority", "available-date", "call-number", "chair", "chapter-number", "citation-key", "citation-label", "citation-number", "collection-editor", "collection-number", "collection-title", "compiler", "composer", "container-author", "container-title", "container-title-short", "contributor", "curator", "dimensions", "director", "division", "DOI", "edition", "editor", "editor-translator", "editorial-director", "event", "event-date", "event-place", "event-title", "executive-producer", "first-reference-note-number", "genre", "guest", "host", "illustrator", "interviewer", "ISBN", "ISSN", "issue", "issued", "jurisdiction", "keyword", "language", "license", "locator", "medium", "narrator", "note", "number", "number-of-pages", "number-of-volumes", "organizer", "original-author", "original-date", "original-publisher", "original-publisher-place", "original-title", "page", "page-first", "part-number", "part-title", "performer", "PMCID", "PMID", "printing-number", "producer", "publisher", "publisher-place", "recipient", "references", "reviewed-author", "reviewed-genre", "reviewed-title", "scale", "script-writer", "section", "series-creator", "source", "status", "submitted", "supplement-number", "title", "title-short", "translator", "URL", "version", "volume", "volume-title", "year-suffix"}) -- from citefield.lua

function Pandoc (doc)
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
   
   -- Background image
   if doc.meta.titlegraphic then
      table.insert(hblocks, pandoc.Para({}))
      table.insert(hblocks, pandoc.Image(doc['meta']['titlegraphic-style'] or {},
                      pandoc.utils.stringify(doc.meta.titlegraphic)))
   end

   -- Logo
   if not doc.meta['logo-position'] then
      doc.meta['logo-position'] = 'top'
   end

   if not doc.meta['logo-style'] then
      doc.meta['logo-style'] = 'left inline'
   end

   local logoimg
   local logopos = pandoc.utils.stringify(doc.meta['logo-position'])
   
   if doc.meta.logo then
      logoimg = pandoc.Image(doc.meta['logo-style'],
                             pandoc.utils.stringify(doc.meta.logo))
   end
   
   if doc.meta.logo and logopos == 'top' then
      table.insert(hblocks, logoimg)
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

      if doc.meta.logo and logopos == 'bottom' then
         table.insert(hblocks, logoimg)
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
   -- If the Pandoc default-image-extension option is used, the
   -- default image extension is also appended to URLs.  This breaks
   -- YouTube embeds.  We specifically check for YouTube (because the
   -- issue doesn't concern URLs in general) and remove the
   -- "extension" if it matches the default image extension.
   if PANDOC_READER_OPTIONS.default_image_extension then
      if el.src:match('youtube.com/watch') or el.src:match('youtu.be/') then
         local path, ext = pandoc.path.split_extension(el.src)

         if ext:match(PANDOC_READER_OPTIONS.default_image_extension) then
            el.src = path
         end
      end
   end

   if el.classes:includes('lecturenotes')  then
      -- Exclude images with the .lecturenotes class.
      return {}
   else
      -- Remove classes and attributes from images (not supported by Deckset)
      return pandoc.Image(el.caption, el.src)
   end
end

function Link(el)
   if el.classes:includes('lecturenotes') then
      -- Exclude links with the .lecturenotes class.
      return {}
   else
      return nil
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

function Para (el)
   -- Handle "dual-use" presenter notes: replace an empty superscript
   -- at the beginning of a paragraph with "^"
   if #el.c > 0 and el.c[1].t == 'Superscript' and #el.c[1].c == 0 then
      el.c[1] = '^'
   end
   return el
end

function Span (el)
   if el.classes:includes("alert") then
      -- Replace spans with the "alert" class (think Beamer) with
      -- Deckset-style "combined emphasis" markup (which may or may not be
      -- different from regular bold or italics).
      table.insert(el.content, 1, pandoc.RawInline('markdown', '_**'))
      table.insert(el.content, pandoc.RawInline('markdown', '**_'))
      return el.content
   end

   if csl_fields:includes(el.classes[1]) then
      -- We assume that this intended for the citefield.lua filter
      return el
   end

   -- Otherwise, replace spans (not supported by Deckset) with their content
   return el.content
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
