
#
# bwa makefile rules
# 

define BWA_USAGE
The following variables must be set:
FASTQDIR	the path to the directory containing the input fastq.gz files
REFERENCE	the reference sequence to align reads to

endef

ifndef BWA
BWA=bwa
endif

ifdef NPROC
BWAFLAGS += -t $(NPROC)
endif

ifdef BWA_MARKSECONDARY
BWA_OPTIONS += -M
endif

ifndef REFERENCE
$(error $(BWA_USAGE))
endif

ifndef FASTQDIR
$(error $(BWA_USAGE))
endif

%.bam: $(REFERENCE) $(FASTQDIR)/%_*.fastq.gz
	$(BWA) mem $(BWAFLAGS) $< $(filter-out $<, $^) | samtools view -Sbh - > $@.tmp && mv $@.tmp $@
