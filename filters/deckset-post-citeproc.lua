local meta;

function Div (el)
   if el.identifier == 'refs' then
      local blocks = {}

      table.insert(blocks, pandoc.HorizontalRule())
      table.insert(blocks,
                   pandoc.Header(1, meta['reference-section-title']
                                 or "References"))

      local biblist = pandoc.BulletList({})
         
      pandoc.walk_block(el, { Div = function(el)
                                 biblist.content:insert(el.content)
      end })

      table.insert(blocks, biblist)

      return blocks
   end
end

function Header (el)
   -- This header is automatically inserted when using the
   -- reference-section-title option.  Remove this header, we handle
   -- this ourselves abov in Div().

   if el.identifier == 'bibliography' then
      return {}
   end
end

function Meta (el)
   -- Copy the metadata and remove it from the document (Deckset
   -- doesn't support any type of metadata header)
   meta = el
   return {} 
end

--- Change order of processing: grab metadata first, because we need
--- it in Div() to build the title slide.

return {
   { Meta = Meta },  -- (1)
   { Div = Div },     -- (2)
   { Header = Header },
}
