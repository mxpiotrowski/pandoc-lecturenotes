BIB=${HOME}/lib/tex/bibtex/bib/all.bib
CSL=pandoc/glossa.csl

slides.md: sample.md
	pandoc -s \
	-t commonmark+footnotes+pipe_tables+strikeout+tex_math_dollars \
	-o $@ \
	--data-dir=${HOME}/lib/pandoc \
	--wrap=none \
	--bibliography=${BIB} \
	--lua-filter=deckset-slides.lua \
	--citeproc \
	--lua-filter=deckset-post-citeproc.lua \
	$<

%.pdf: %.md
	pandoc -s -t pdf -o $@ \
	--data-dir=${HOME}/lib/pandoc \
	--number-sections \
	--lua-filter=scholarly-metadata.lua \
	--lua-filter=author-info-blocks.lua \
	--lua-filter=pandoc/conditional-notes.lua \
	--lua-filter=embed-slides.lua \
	--bibliography=${BIB} \
	--csl=${CSL} --citeproc \
	--pdf-engine=xelatex $<

%.tex: %.md
	pandoc -s -t latex -o $@ \
	--data-dir=${HOME}/lib/pandoc \
	--number-sections \
	--lua-filter=scholarly-metadata.lua \
	--lua-filter=author-info-blocks.lua \
	--lua-filter=pandoc/conditional-notes.lua \
	--lua-filter=embed-slides.lua \
	--bibliography=${BIB} \
	--csl=${CSL} --citeproc \
	--pdf-engine=xelatex $<

# %.pdf: %.md
# 	PATH=/opt/groff/bin:$$PATH pandoc -s -t pdf \
# 	--data-dir=${HOME}/lib/pandoc \
# 	--number-sections \
# 	--lua-filter=scholarly-metadata.lua \
# 	--lua-filter=author-info-blocks.lua \
# 	--lua-filter=pandoc/groff-fixes.lua \
# 	--lua-filter=pandoc/conditional-notes.lua \
# 	--lua-filter=embed-slides.lua -o $@ \
# 	--bibliography=${BIB} \
# 	--csl=${CSL} --citeproc \
# 	--pdf-engine=pdfroff --pdf-engine-opt=-dpaper=a4 \
# 	--pdf-engine-opt=-U \
# 	--pdf-engine-opt=-P-pa4 --pdf-engine-opt=-mfr --pdf-engine-opt=-mde $<

%.ms: %.md
	PATH=/opt/groff/bin:$$PATH pandoc -s -t ms \
	  --data-dir=${HOME}/lib/pandoc \
	  --number-sections \
	  --lua-filter=scholarly-metadata.lua \
	  --lua-filter=author-info-blocks.lua \
	  --lua-filter=pandoc/groff-fixes.lua \
	  --lua-filter=pandoc/conditional-notes.lua \
	  --lua-filter=embed-slides.lua -o $@ \
	  --bibliography=${BIB} \
	  --csl=${CSL} --citeproc \
	  --pdf-engine=pdfroff --pdf-engine-opt=-dpaper=a4 \
	  --pdf-engine-opt=-P-pa4 --pdf-engine-opt=-mfr --pdf-engine-opt=-mde $<
