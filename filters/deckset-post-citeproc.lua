local meta;

function Meta (el)
   -- Copy the metadata and remove it from the document (Deckset
   -- doesn't support any type of metadata header)
   meta = el
   return {} 
end

function Div (el)
   if el.identifier == 'refs' then
      local blocks = {}

      table.insert(blocks, pandoc.HorizontalRule())
      table.insert(blocks,
                   pandoc.Header(1, meta['reference-section-title']
                                 or "References"))

      -- Make sure the list of references is left-aligned and uses a
      -- plain bullet; the default em-dash works for most themes, but
      -- can be customized using the bibliography-bullet metadata
      -- option.
      local bullet = pandoc.utils.stringify(meta['bibliography-bullet'] or '—')
      table.insert(blocks, pandoc.RawBlock(FORMAT, '[.autoscale: true]\n'
                                           .. '[.list: alignment(left), '
                                           .. 'bullet-character(' .. bullet .. ')]'))

      local biblist = pandoc.BulletList({})
         
      -- A bibliography item produced by citeproc is a Div containing
      -- a Para.  We iterate over the Paras, take their content, and
      -- rewrap it in a Plain.  Directly inserting the Div or the Para
      -- would make Pandoc output a "loose" list (with an empty line
      -- between items), which is not formatted correctly by Deckset.
      
      pandoc.walk_block(el, {
                           Para = function (para)
                              biblist.content:insert(
                                 { pandoc.Plain(para.content) }
                              )
                           end
      })
      
      table.insert(blocks, biblist)
      
      return blocks
   end
end

function Header (el)
   -- This header is automatically inserted when using the
   -- reference-section-title option.  Remove this header, we handle
   -- this ourselves above in Div().

   if el.identifier == 'bibliography' then
      return {}
   end
end

--- Change order of processing: grab metadata first, because we need
--- it in Div() to build the title slide.

return {
   { Meta = Meta },
   { Div = Div },
   { Header = Header },
}
