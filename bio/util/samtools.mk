#!/usr/bin/make -rRf

#
# samtools makefile rules
# 

.PHONY: samtools-header samtools-settings
.DELETE_ON_ERROR:

# samtools
ifndef SAMTOOLS
SAMTOOLS=samtools
endif
ifndef SAMTOOLS_OPTIONS
SAMTOOLS_OPTIONS=
endif

SAMTOOLS_VIEWFLAGS += --threads $(NPROC)

SAMTOOLS_SORTFLAGS += --threads $(NPROC)

# Index a FASTA file
%.fai: %
	$(SAMTOOLS) faidx $<

# Convert a SAM file to a BAM file
%.bam: %.sam
	$(SAMTOOLS) view $(SAMTOOLS_VIEWFLAGS) -b $< -o $@

# Convert a BAM file to a SAM file
%.bam.sam: %.bam
	$(SAMTOOLS) view $(SAMTOOLS_VIEWFLAGS) -h $< >$@

# Sort a SAM file and create a BAM file
%.bam: %.unsorted.sam
	$(SAMTOOLS) view $(SAMTOOLS_VIEWFLAGS) -Su $< \
	| $(SAMTOOLS) sort $(SAMTOOLS_SORTFLAGS) - -o $@

%.sam: %.unsorted.sam
	$(SAMTOOLS) sort $(SAMTOOLS_SORTFLAGS) $< -o $@

# Sort a BAM file
%.sort.bam: %.bam
	$(SAMTOOLS) sort $(SAMTOOLS_SORTFLAGS) $< $*.sort

# Sort a BAM file by query name
%.qsort.bam: %.bam
	$(SAMTOOLS) sort $(SAMTOOLS_SORTFLAGS) -no $< - >$@

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
