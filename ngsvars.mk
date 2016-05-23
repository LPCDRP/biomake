#
#
# ngs variable settings
# 
ifndef REF
REF=
endif

ifndef JAVA_MEM
JAVA_MEM=6g
endif

ifndef JAVA_TMPDIR
JAVA_TMPDIR=/tmp
endif

ifndef THREADS
THREADS=8
endif

ifndef DBSNP
DBSNP=
endif

ifndef TARGET_REGIONS
TARGET_REGIONS=
endif

ifndef BAIT_REGIONS
BAIT_REGIONS=
endif

ifndef INPUTDIR
INPUTDIR=.
endif

# Labels for read files
ifndef READ1_LABEL
READ1_LABEL=_R1_001
endif
ifndef READ2_LABEL
READ2_LABEL=_R2_001
endif

##############################
# NB: the following variables are tailored for use on data generated at SciLife Stockholm
##############################
# The following variables should be set in calling Makefile
ifndef SAMPLE_PREFIX
SAMPLE_PREFIX=P00
endif
ifndef FLOWCELL_SUFFIX
FLOWCELL_SUFFIX=XX
endif
ifndef SAMPLES
SAMPLES = $(wildcard $(SAMPLE_PREFIX)*)
endif
ifndef FLOWCELLRUNS
FLOWCELLRUNS = $(foreach s,$(SAMPLES),$(wildcard $(s)/*$(FLOWCELL_SUFFIX)))
endif
# ifndef FLOWCELLS
# FLOWCELLS= $(subst /, ,$(foreach s,$(SAMPLES),$(wildcard $(s)/*$(FLOWCELL_SUFFIX))))
# endif
# Requirement: directory name == sample name
# TODO: Fix filtering based on flowcell name
ifndef FASTQFILES
#FASTQFILES = $(foreach f,$(FLOWCELLS),$(foreach s,$(SAMPLES),$(wildcard $(s)/$(f)/*$(READ1_LABEL).fastq.gz)))
FASTQFILES = $(foreach s,$(SAMPLES),$(wildcard $(s)/*/*$(READ1_LABEL).fastq.gz))
endif


##############################
# Settings
##############################
.PHONY: ngsvars-settings ngsvars-header

print-%:
	@echo '$*=$($*)'

print-SAMPLES:
	@echo -e '\nSAMPLES=$(SAMPLES)'

print-FLOWCELLRUNS:
	@echo -e '\nFLOWCELLRUNS=$(FLOWCELLRUNS)'

print-FASTQFILES:
	@echo -e '\nFASTQFILES=$(FASTQFILES)'

ngsvars-header:
	@echo -e "\nngsvars.mk options"
	@echo "========================"


ngsvars-settings: ngsvars-header print-REF print-DBSNP print-JAVA_MEM print-THREADS print-TARGET_REGIONS print-BAIT_REGIONS print-INPUTDIR print-READ1_LABEL print-READ2_LABEL print-SAMPLE_PREFIX print-FLOWCELL_SUFFIX print-SAMPLES print-FLOWCELLRUNS print-FASTQFILES
