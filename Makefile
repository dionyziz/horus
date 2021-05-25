PACKAGE=acmart

SAMPLES = horus.tex

PDF = $(PACKAGE).pdf ${SAMPLES:%.tex=%.pdf}

all: ${PDF}

horus.pdf: *.tex *.bib algorithms/*.tex
	xelatex horus.tex && \
	bibtex horus && \
	xelatex horus.tex && \
	xelatex horus.tex && \
	rm -rf *.aux *.log *.out;

minimal:
	xelatex horus.tex

clean:
	$(RM)  *.log *.aux \
	*.cfg *.glo *.idx *.toc \
	*.ilg *.ind *.out *.lof \
	*.lot *.bbl *.blg *.gls *.cut *.hd \
	*.dvi *.ps *.thm *.tgz *.zip *.rpi \
	*.d *.fls *.*.make
	$(RM) horus.pdf

distclean: clean
	$(RM) $(PDF) *-converted-to.pdf
