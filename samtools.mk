#!/usr/bin/make -rRf

#
# samtools makefile rules
# 

.PHONY: samtools-header samtools-settings
.DELETE_ON_ERROR:
.SECONDARY:

MAKEDIR = $(dir $(lastword $(MAKEFILE_LIST)))
ifeq ($(findstring ngsvars.mk,$(MAKEFILE_LIST)),)
include $(MAKEDIR)ngsvars.mk
endif

# samtools
ifndef SAMTOOLS
SAMTOOLS=samtools
endif
ifndef SAMTOOLS_OPTIONS
SAMTOOLS_OPTIONS=
endif

# Index a FASTA file
%.fa.fai: %.fa
	$(SAMTOOLS) faidx $<

# Convert a SAM file to a BAM file
%.bam: %.sam
	$(SAMTOOLS) view -Sb - > $@.tmp && mv $@.tmp $@

# Convert a BAM file to a SAM file
%.bam.sam: %.bam
	$(SAMTOOLS) view -h $< >$@

# Sort a SAM file and create a BAM file
%.sort.bam: %.sam
	$(SAMTOOLS) view -Su $< |$(SAMTOOLS) sort - $*.sort

# Sort a BAM file
%.sort.bam: %.bam
	$(SAMTOOLS) sort $< $*.sort

# Sort a BAM file by query name
%.qsort.bam: %.bam
	$(SAMTOOLS) sort -no $< - >$@

# Index a BAM file
%.bam.bai: %.bam
	$(SAMTOOLS) index $<

# Fix the mate pair information of a BAM file
%.fixmate.bam: %.qsort.bam
	$(SAMTOOLS) fixmate $< $@

# Remove duplicates from a BAM file
%.rmdup.bam: %.bam
	$(SAMTOOLS) rmdup $< $@

# Count flags of a BAM file
%.flagstat: %.bam
	$(SAMTOOLS) flagstat $< >$@

# Report BAM index stats
%.idxstats.tsv: %.bam %.bam.bai
	(printf 'tid\tlength\tnumMapped\tnumUnmapped\n' \
		&& $(SAMTOOLS) idxstats $<) >$@

##############################
# settings
##############################
.PHONY: samtools-settings samtools-header

print-%:
	@echo '$*=$($*)'

samtools-header:
	@echo -e "\nsamtools.mk options"
	@echo "========================="


samtools-settings: samtools-header print-SAMTOOLS print-NPROC print-SAMTOOLS_OPTIONS print-REFERENCE
