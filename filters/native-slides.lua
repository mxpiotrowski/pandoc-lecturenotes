--- native-slides.lua – filter for extracting slides for formats
--- natively supported by Pandoc
---
--- Copyright © 2026 Michael Piotrowski
--- Licensed under the terms of the MIT License; see LICENSE file for details

function Pandoc (doc)
   local hblocks = {}

   for i, el in pairs(doc.blocks) do
      if (el.t == "Div" and el.classes:includes("slide")) then
         table.insert(hblocks, pandoc.HorizontalRule())

         for j, e in pairs(el.content) do
            table.insert(hblocks, e)
         end
      end
   end
   
   return pandoc.Pandoc(hblocks, doc.meta)
end

function Figure (el)
   return el.content[1]
end

function Image (el)
   -- Exclude images with the .lecturenotes class.
   if el.classes:includes('lecturenotes')  then
      return {}
   end
end

function Div (el)
   -- Exclude Divs with the .lecturenotes class.
   if el.classes:includes("lecturenotes") then
      return {}
   end
end
