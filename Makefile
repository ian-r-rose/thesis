# This work is dedicated to the public domain.

texargs = -interaction nonstopmode -halt-on-error -file-line-error

default: mthesis.pdf # default target if you just type "make"


# Resources and rules for the introductory chapter. Sample 'make' rule
# included to show how you can process data as you compile your thesis
# using standard GNU make constructs.

deps += intro/intro.tex
cleans += intro/intro.aux

# Chapter One

deps += tpw_rate/tpw_rate.tex tpw_rate/tpw_rate_chapter.tex
cleans += tpw_rate/tpw_rate_chapter.aux tpw_rate/tpw_rate_chapter.tex

tpw_rate/tpw_rate_chapter.tex: tpw_rate/tpw_rate.tex tpw_rate/frontmatter.tex
	make -C tpw_rate
	sed -ne 's@{figures/@{tpw_rate/figures/@; /%%BEGINCLIP/,/%%ENDCLIP/p' $< > tpw_rate/processed.tex
	cat tpw_rate/frontmatter.tex tpw_rate/processed.tex > $@

# Chapter Two

deps += free_surface/free_surface_chapter.tex free_surface/free-surface-paper.tex
cleans += tpw_rate/free_surface_chapter.aux free_surface/free_surface_chapter.tex

free_surface/free_surface_chapter.tex: free_surface/free-surface-paper.tex free_surface/frontmatter.tex
	make -C free_surface
	sed -ne 's@{figures/@{free_surface/figures/@; /%%BEGINCLIP/,/%%ENDCLIP/p' $< > free_surface/processed.tex
	cat free_surface/frontmatter.tex free_surface/processed.tex > $@

# Chapter Three

deps += bayesian_plate_reconstruction/bayesian_plate_reconstruction_chapter.tex \
        bayesian_plate_reconstruction/bayesian_plate_reconstruction.tex
cleans += tpw_rate/bayesian_plate_reconstruction_chapter.aux \
          bayesian_plate_reconstruction/bayesian_plate_reconstruction_chapter.tex

bayesian_plate_reconstruction/bayesian_plate_reconstruction_chapter.tex: \
        bayesian_plate_reconstruction/bayesian_plate_reconstruction.tex bayesian_plate_reconstruction/frontmatter.tex
	make -C bayesian_plate_reconstruction
	sed -ne 's@{figures/@{bayesian_plate_reconstruction/figures/@; /%%BEGINCLIP/,/%%ENDCLIP/p' $< > bayesian_plate_reconstruction/processed.tex
	cat bayesian_plate_reconstruction/frontmatter.tex bayesian_plate_reconstruction/processed.tex > $@




## Bibliography

deps += free_surface/free-surface-paper.bib tpw_rate/tpw_rate.bib bayesian_plate_reconstruction/bayesian_plate_reconstruction.bib
thesis.bib: free_surface/free-surface-paper.bib tpw_rate/tpw_rate.bib bayesian_plate_reconstruction/bayesian_plate_reconstruction.bib
	bibtool -s -d free_surface/free-surface-paper.bib tpw_rate/tpw_rate.bib bayesian_plate_reconstruction/bayesian_plate_reconstruction.bib> $@



# The thesis itself. We move the PDF to a new filename so that viewers
# don't keep on trying to reload the file as it's being written and
# rewritten by pdfLaTeX.

deps += myucthesis.cls uct12.clo mymacros.sty mydeluxetable.sty \
  setup.tex thesis.bib elsarticle-harv.bst
cleans += thesis.aux thesis.bbl thesis.blg thesis.lof thesis.log \
  thesis.lot thesis.out thesis.toc mthesis.pdf setup.aux
toplevels += mthesis.pdf

mthesis.pdf: thesis.tex $(deps)
	pdflatex $(texargs) $(basename $<) >chatter.txt
	bibtex $(basename $<)
	pdflatex $(texargs) $(basename $<) >chatter.txt
	pdflatex $(texargs) $(basename $<) >chatter.txt
	mv thesis.pdf $@


# Approval page

cleans += approvalpage.aux approvalpage.log approvalpage.pdf
toplevels += approvalpage.pdf

approvalpage.pdf: approvalpage.tex $(deps)
	pdflatex $(texargs) $(basename $<)


# Helpers

all: $(toplevels)

clean:
	-rm -f $(cleans)
