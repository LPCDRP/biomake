outdir ?= .

MAKEDIR = $(dir $(lastword $(MAKEFILE_LIST)))
ifeq ($(findstring ngsvars.mk,$(MAKEFILE_LIST)),)
include $(MAKEDIR)ngsvars.mk
endif

#
# bedtools makefile settings
# 
ifndef BEDTOOLS_HOME
BEDTOOLS_HOME=.
endif
ifndef BEDTOOLS_OPTIONS
BEDTOOLS_OPTIONS=
endif
ifndef BEDTOOLS_BFILE
BEDTOOLS_BFILE=
endif

# coverageBed
$(outdir)/%.coverage: %.bam
	$(BEDTOOLS_HOME)/coverageBed $(BEDTOOLS_OPTIONS) -abam $< -b $(BEDTOOLS_BFILE) > $@.tmp && mv $@.tmp $@

# Convert to and from pos files, where pos files correspond to the first 
