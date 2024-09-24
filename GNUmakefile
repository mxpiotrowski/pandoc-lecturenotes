BIB=references.bib

%-deckset.md: %.md filters/deckset-slides.lua
	pandoc -s -f markdown-implicit_figures \
	-t commonmark+footnotes+pipe_tables+strikeout+tex_math_dollars \
	-o $@ \
	--wrap=none \
	--bibliography=${BIB} \
	-L filters/deckset-slides.lua \
	--citeproc \
	-L filters/deckset-post-citeproc.lua \
	$<

%-latex.pdf: %.md filters/embed-slides.lua
	pandoc -s -f markdown-implicit_figures -t pdf -o $@ \
	--number-sections \
	-L filters/embed-slides.lua \
	--citeproc --bibliography=${BIB} \
	--pdf-engine=xelatex $<

%-ms.pdf: %.md filters/embed-slides.lua
	pandoc -s -f markdown-implicit_figures -t pdf -o $@ \
	--number-sections \
	-L filters/embed-slides.lua \
	--citeproc --bibliography=${BIB} \
	--pdf-engine=pdfroff --pdf-engine-opt=-dpaper=a4 \
	--pdf-engine-opt=-U --pdf-engine-opt=-P-pa4 $<

%.html: %.md filters/embed-slides.lua embed-slides.css
	pandoc -s -f markdown-implicit_figures -t html5 \
	  -L filters/embed-slides.lua -c embed-slides.css \
	  --mathml \
	  --toc=true --citeproc --bibliography=${BIB} \
	  -o $@ $<

.PHONY: clean

clean:
	rm -f *-deckset.md *-{latex,ms}.pdf *.html *~
