BIB=references.bib

%-deckset.md: sample.md
	pandoc -s -f markdown-implicit_figures \
	-t commonmark+footnotes+pipe_tables+strikeout+tex_math_dollars \
	-o $@ \
	--wrap=none \
	--bibliography=${BIB} \
	-L filters/deckset-slides.lua \
	--citeproc \
	-L filters/deckset-post-citeproc.lua \
	$<

%-latex.pdf: %.md
	pandoc -s -f markdown-implicit_figures -t pdf -o $@ \
	--number-sections \
	-L filters/embed-slides.lua \
	--citeproc --bibliography=${BIB} \
	--pdf-engine=xelatex $<

%-ms.pdf: %.md
	pandoc -s -f markdown-implicit_figures -t pdf -o $@ \
	--number-sections \
	-L filters/embed-slides.lua \
	--citeproc --bibliography=${BIB} \
	--pdf-engine=pdfroff --pdf-engine-opt=-dpaper=a4 \
	--pdf-engine-opt=-U --pdf-engine-opt=-P-pa4 $<

clean:
	rm -f *-{deckset,latex,ms}.{md,pdf} *~
