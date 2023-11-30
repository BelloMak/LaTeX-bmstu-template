# Для работы данного файла необходимо установить make, grep и nhcolor
# (отвечает за цветной вывод ошибок, можно убрать; URL:
# https://nhutils.ru/blog/цвет-текста-в-командном-файле/) и прописать их в PATH.
# Также необходимо установить пакет texlogsieve в MikTex (отвечает за вывод
# warning; URL: https://www.ctan.org/tex-archive/support/texlogsieve?lang=en).

# Для работы draft мода необходимо в main файле вместо 
# \documentclass{bmstu}
# написать: 
# \providecommand\classopts{}
# \expandafter\documentclass\expandafter[\classopts]{bmstu}

# Также для корректного отображения warning необходимо вынести титульный лист за
# пределы main файла в titlepage.tex и добавлять его в РПЗ с помощью 
# \includepdf{titlepage.pdf}

SHELL = cmd

TEX_SOURCE := main
TITLE_SOURCE := titlepage

FINALPARAM = -interaction=nonstopmode -file-line-error -halt-on-error

DRAFTPARAM = -interaction=errorstopmode -file-line-error -halt-on-error

TEXLOGSIEVEPARAM = --only-summary --color --summary-detail --repetitions \
	--no-heartbeat --no-box-detail

GREPPARAM = -m 1 -A 1 -E "*[.]tex:[0-9]+:|!pdfTeX error"

TEMP_FILES = *.aux *.bbl *.bcf *.blg *.log *.out *.run.xml *.toc

TRASH := nul

.PHONY: -s title
.SILENT: -s title
title:
	pdflatex $(FINALPARAM) $(TITLE_SOURCE).tex | grep $(GREPPARAM) | nhcolor 0c
	grep $(GREPPARAM) $(TITLE_SOURCE).log > $(TRASH) || echo Title done! | nhcolor 02
	make -s clean > $(TRASH)

.PHONY: -s final
.SILENT: -s final
final:
	make -s cleanall > $(TRASH)
	make -s title
	pdflatex $(FINALPARAM) $(TEX_SOURCE).tex | grep $(GREPPARAM) | nhcolor 0c 
	biber $(TEX_SOURCE) > $(TRASH) 
	echo Biber done! | nhcolor 02
	pdflatex $(FINALPARAM) $(TEX_SOURCE).tex > $(TRASH)
	pdflatex $(FINALPARAM) $(TEX_SOURCE).tex | texlogsieve $(TEXLOGSIEVEPARAM)
	make -s clean > $(TRASH)
	echo Final file done! | nhcolor 02

.PHONY: -s build
.SILENT: -s build
build:
	make -s clean > $(TRASH)
	pdflatex $(FINALPARAM) $(TEX_SOURCE).tex | grep $(GREPPARAM) | nhcolor 0c 
	biber $(TEX_SOURCE) > $(TRASH) 
	echo Biber done! | nhcolor 02
	pdflatex $(FINALPARAM) $(TEX_SOURCE).tex | texlogsieve $(TEXLOGSIEVEPARAM)
	make -s clean > $(TRASH)
	echo Build done! | nhcolor 02
	
.PHONY: draft
.SILENT: draft
draft:
	pdflatex $(DRAFTPARAM) "\def\classopts{draft}\input{$(TEX_SOURCE).tex}" \
	|(texlogsieve $(TEXLOGSIEVEPARAM) & grep $(GREPPARAM) $(TEX_SOURCE).log | nhcolor 0c)
	grep $(GREPPARAM) $(TEX_SOURCE).log > $(TRASH) || echo Draft done! | nhcolor 02

.PHONY: clean
.SILENT: clean
clean:
	del /s $(TEMP_FILES) > $(TRASH) 2>&1 
	echo Clean done! | nhcolor 02

.PHONY: cleanall
.SILENT: cleanall
cleanall:
	del /s $(TEMP_FILES) > $(TRASH) 2>&1
	del $(TEX_SOURCE).pdf 2> $(TRASH)
	del $(TITLE_SOURCE).pdf 2> $(TRASH)
	echo Cleanall done! | nhcolor 02