# Среда исполнения
SHELL = cmd

# Название главного tex файла
TEX_SOURCE := main
# Название tex файла титульника														
TITLE_SOURCE := titlepage

# Параметры запуска make final
FINALPARAM = -interaction=nonstopmode -file-line-error -halt-on-error
# Параметры запуска make draft
DRAFTPARAM = -interaction=errorstopmode -file-line-error -halt-on-error

# Параметры запуска пакета toxlogsieve
TEXLOGSIEVEPARAM = --only-summary --color --summary-detail --repetitions \
	--no-heartbeat --no-box-detail

# Параметры поиска ошибок в pdflatex логах
GREPPARAM_TEX = -m 1 -A 1 -E "*[.]tex:[0-9]+:|!pdfTeX error"
# Параметры поиска ошибок в biber логах
GREPPARAM_BIB_ERR = -E "ERROR"
GREPPARAM_BIB_WAR = -E "WARN"

# Расширения временных файлов
TEMP_FILES = *.aux *.bbl *.bcf *.blg *.log *.out *.run.xml *.toc *.mylog

TRASH := nul

.PHONY: -s title
.SILENT: -s title
title:
	pdflatex $(FINALPARAM) $(TITLE_SOURCE).tex | grep $(GREPPARAM_TEX) | nhcolor 0c
	grep $(GREPPARAM_TEX) $(TITLE_SOURCE).log > $(TRASH) || echo Title done! \
	| nhcolor 02
	make -s clean > $(TRASH)

.PHONY: -s final
.SILENT: -s final
final:
	make -s cleanall > $(TRASH)
	make -s title
	pdflatex $(FINALPARAM) $(TEX_SOURCE).tex | grep $(GREPPARAM_TEX) | nhcolor 0c 
	biber $(TEX_SOURCE) > main.mylog || ( \
	grep $(GREPPARAM_BIB_ERR) $(TEX_SOURCE).mylog | nhcolor 0c)
	grep $(GREPPARAM_BIB_WAR) $(TEX_SOURCE).mylog | nhcolor 0e
	grep $(GREPPARAM_BIB_ERR) $(TEX_SOURCE).mylog > $(TRASH) || \
	((echo Biber done! | nhcolor 02) & (\
	pdflatex $(FINALPARAM) $(TEX_SOURCE).tex > $(TRASH) & \
	pdflatex $(FINALPARAM) $(TEX_SOURCE).tex | texlogsieve $(TEXLOGSIEVEPARAM) & \
	make -s clean > $(TRASH) & \
	echo Final file done! | nhcolor 02))

.PHONY: -s build
.SILENT: -s build
build:
	make -s clean > $(TRASH)
	pdflatex $(FINALPARAM) $(TEX_SOURCE).tex | grep $(GREPPARAM_TEX) | nhcolor 0c 
	biber $(TEX_SOURCE) > main.mylog || ( \
	grep $(GREPPARAM_BIB_ERR) $(TEX_SOURCE).mylog | nhcolor 0c)
	grep $(GREPPARAM_BIB_WAR) $(TEX_SOURCE).mylog | nhcolor 0e
	grep $(GREPPARAM_BIB_ERR) $(TEX_SOURCE).mylog > $(TRASH) || \
	((echo Biber done! | nhcolor 02) & (\
	pdflatex $(FINALPARAM) $(TEX_SOURCE).tex | texlogsieve $(TEXLOGSIEVEPARAM) & \
	make -s clean > $(TRASH) & \
	echo Build done! | nhcolor 02))
	
.PHONY: draft
.SILENT: draft
draft:
	pdflatex $(DRAFTPARAM) "\def\classopts{draft}\input{$(TEX_SOURCE).tex}" \
	|(texlogsieve $(TEXLOGSIEVEPARAM) & grep $(GREPPARAM_TEX) $(TEX_SOURCE).log \
	| nhcolor 0c)
	grep $(GREPPARAM_TEX) $(TEX_SOURCE).log > $(TRASH) || echo Draft done! \
	| nhcolor 02

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