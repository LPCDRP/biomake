outdir ?= .

#
# plink makefile rules
# 

ifndef PLINK
PLINK=plink
endif
ifndef PLINK_OPTIONS_COMMON
PLINK_OPTIONS_COMMON=--noweb
endif
ifndef PLINK_OPTIONS
PLINK_OPTIONS=$(PLINK_OPTIONS_COMMON)
endif

$(outdir)/%.r2.ld: %.ped
	$(PLINK) $(PLINK_OPTIONS)  --file $* --r2 --out $(@:.ld=) 

$(outdir)/%.r2.ld: %.bed
	$(PLINK) $(PLINK_OPTIONS)  --bfile $* --r2 --out $(@:.ld=)

$(outdir)/%.bed: %.ped
	$(PLINK) $(PLINK_OPTIONS)  --file $* --make-bed --out $*

$(outdir)/%.blocks: %.bed
	$(PLINK) $(PLINK_OPTIONS)  --bfile $* --blocks --out $*

$(outdir)/%.chr$(PLINK_CHR).bed: %.bed
	$(PLINK) $(PLINK_OPTIONS)  --bfile $* --chr $(PLINK_CHR) --make-bed --out $*.chr$(PLINK_CHR)


