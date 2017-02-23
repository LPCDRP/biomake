
#
# bwa makefile rules
# 

define BWA_USAGE
The following variables must be set:
BWA_READ1	suffix of forward read pair (example: 1P if your filename is sample_1P.fastq.gz)
BWA_READ2	suffix of reverse read pair
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

ifndef BWA_READ1
$(error $(BWA_USAGE))
endif

ifndef BWA_READ2
$(error $(BWA_USAGE))
endif

%.unsorted.sam: $(REFERENCE) %_$(BWA_READ1).fastq.gz %_$(BWA_READ2).fastq.gz
	$(BWA) mem $(BWAFLAGS) $< $(filter-out $<, $^) > $@
