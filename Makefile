# Makefile for creating the R package hiker

PKGNAME := hiker
PKGVERS = $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" ./$(PKGNAME)/DESCRIPTION)
PKGTAR = $(PKGNAME)_$(PKGVERS).tar.gz
TEXCMD := pdflatex
RFILES := Allclasses.R score.R

all: deps tex pdf pkg check
tex: $(PKGNAME).tex
pdf: $(PKGNAME).pdf

deps:
	Rscript -e 'if (!require("devtools")) install.packages("devtools")'
	Rscript -e 'if (!require("Rnoweb")) install.packages("Rnoweb_1.1.tar.gz", repos = NULL, type="source")'

$(PKGNAME).tex: $(PKGNAME).Rnw
	Rscript -e 'library(Rnoweb); noweb("$(PKGNAME).Rnw", tangle = FALSE)'

$(PKGNAME).pdf: $(PKGNAME).tex
	$(TEXCMD) $<
	$(TEXCMD) $<
	bibtex $(PKGNAME).aux
	$(TEXCMD) $<

pkg: $(PKGNAME).Rnw
	Rscript -e 'library(Rnoweb); noweb("$(PKGNAME).Rnw", weave = FALSE)'
# creating package skeleton
	if [ ! -d "$(PKGNAME)" ]; then mkdir $(PKGNAME);  fi
	if [ ! -d "$(PKGNAME)/R" ]; then mkdir $(PKGNAME)/R;  fi
# handling R files
	find ./$(PKGNAME)/R/ -type f -delete
	mv DESCRIPTION.R $(PKGNAME)/DESCRIPTION
	mv $(RFILES) $(PKGNAME)/R/
# handling man files
	if [ ! -d "$(PKGNAME)/man" ]; then mkdir $(PKGNAME)/man;  fi
	find ./$(PKGNAME)/man/ -type f -delete
	Rscript -e 'library(devtools); devtools::document(pkg = "./$(PKGNAME)")'
# building the source tarball
	R CMD build $(PKGNAME)

check: pkg
	R CMD check $(PKGTAR)

clean:
	$(RM) -r $(PKGNAME).Rcheck/
	$(RM) $(PKGNAME).aux $(PKGNAME).log $(PKGNAME).out $(PKGNAME).bbl $(PKGNAME).blg

