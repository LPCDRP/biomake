
#
# bwa makefile rules
# 

MAKEDIR = $(dir $(lastword $(MAKEFILE_LIST)))
ifeq ($(findstring ngsvars.mk,$(MAKEFILE_LIST)),)
include $(MAKEDIR)ngsvars.mk
endif
ifeq ($(findstring samtools.mk,$(MAKEFILE_LIST)),)
include $(MAKEDIR)samtools.mk
endif

# bwa
ifndef BWA
BWA=bwa
endif
ifndef BWA_NPROC
BWA_NPROC=$(NPROC)
endif
# -M: mark shorter split reads as secondary (compatibility with GATK and picard)
ifndef BWA_OPTIONS
BWA_OPTIONS=-t $(BWA_NPROC) -M
endif
ifndef BWA_REF
BWA_REF=$(REF)
endif

%.bam: %$(READ1_LABEL).fastq.gz %$(READ2_LABEL).fastq.gz
	$(BWA) mem $(BWA_OPTIONS) $(BWA_REF) $^ | $(SAMTOOLS) view -Sbh - > $@.tmp && mv $@.tmp $@

##############################
# settings
##############################
.PHONY: bwa-settings bwa-header

print-%:
	@echo '$*=$($*)'

bwa-header:
	@echo -e "\nbwa.mk options"
	@echo "===================="


bwa-settings: bwa-header print-BWA print-BWA_NPROC print-BWA_OPTIONS print-BWA_REF
