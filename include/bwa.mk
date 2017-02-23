
#
# bwa makefile rules
# 

ifndef BWA
BWA=bwa
endif

ifdef NPROC
BWAFLAGS += -t $(NPROC)
endif

ifdef BWA_MARKSECONDARY
BWA_OPTIONS += -M
endif

ifndef FASTQDIR
$(error FASTQDIR must be defined as the path to the directory containing the input fastq.gz files)
endif

%.bam: $(REFERENCE) $(FASTQDIR)/%_*.fastq.gz
	$(BWA) mem $(BWAFLAGS) $< $(filter-out $<, $^) | samtools view -Sbh - > $@.tmp && mv $@.tmp $@
