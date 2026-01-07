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

function Meta (el)
   -- Set the date in the document’s metadata to the current date, if
   -- a date isn’t already set

   if el.date == nil then
      el.date = os.date("%F")

      return el
   end
end
