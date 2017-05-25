outdir ?= .

#
# picard makefile rules
# 

MAKEDIR = $(dir $(lastword $(MAKEFILE_LIST)))
ifeq ($(findstring ngsvars.mk,$(MAKEFILE_LIST)),)
include $(MAKEDIR)ngsvars.mk
endif

.PRECIOUS: %.bai

# PICARD_HOME variable
ifndef PICARD_HOME
PICARD_HOME=.
endif
ifndef PICARD_JAVA_MEM
PICARD_JAVA_MEM=$(JAVA_MEM)
endif
ifndef PICARD_JAVA_TMPDIR
PICARD_JAVA_TMPDIR=$(JAVA_TMPDIR)
endif
ifndef PICARD_JAVA
PICARD_JAVA=java -Xmx$(PICARD_JAVA_MEM) -Djava.io.tmpdir=$(PICARD_JAVA_TMPDIR) -jar 
endif

# Bait and target regions
ifndef PICARD_TARGET_REGIONS
PICARD_TARGET_REGIONS=$(TARGET_REGIONS)
endif

ifndef PICARD_BAIT_REGIONS
PICARD_BAIT_REGIONS=$(BAIT_REGIONS)
endif

# Common options
ifndef PICARD_OPTIONS_COMMON
PICARD_OPTIONS_COMMON=VALIDATION_STRINGENCY=SILENT
endif
ifndef PICARD_OPTIONS
PICARD_OPTIONS=$(PICARD_OPTIONS_COMMON)
endif

# Bam index
$(outdir)/%.bai: %.bam
	$(PICARD_JAVA) $(PICARD_HOME)/BuildBamIndex.jar I=$< O=$@.tmp $(PICARD_OPTIONS) && mv $@.tmp $@

ifndef PICARD_OPTION_SORTSAM
PICARD_OPTION_SORTSAM=SORT_ORDER=coordinate
endif
$(outdir)/%.sort.bam: %.bam
	$(PICARD_JAVA) $(PICARD_HOME)/SortSam.jar I=$< O=$@.tmp $(PICARD_OPTIONS) $(PICARD_OPTION_SORTSAM) && mv $@.tmp $@

$(outdir)/%.dup.bam: %.bam
	$(PICARD_JAVA) $(PICARD_HOME)/MarkDuplicates.jar I=$< O=$@.tmp $(PICARD_OPTIONS) M=$(@:.bam=).dup_metrics && mv $@.tmp $@

$(outdir)/%.interval_list: $(REFERENCE)
	$(PICARD_JAVA) $(PICARD_HOME)/CreateSequenceDictionary.jar R=$< O=$@.tmp && mv $@.tmp $@

$(outdir)/%.interval_list: %.bed $(subst .fa,.interval_list,$(REFERENCE))
	$(CAT) $(lastword $^) > $@.tmp
	$(AWK) '{printf("%s\t%s\t%s\t%s\t%s\n", $$1,$$2,$$3,"+",$$4)}' $< >> $@.tmp && mv $@.tmp $@

##############################
# Metrics calculations
##############################
$(outdir)/%.insert_metrics: %.bam %.bai
	$(PICARD_JAVA) $(PICARD_HOME)/CollectInsertSizeMetrics.jar $(PICARD_OPTIONS) H=$*.hist I=$< O=$@.tmp R=$(REFERENCE) && mv $@.tmp $@

# Dup metrics - see also %.dup.bam
$(outdir)/%.dup_metrics: %.bam %.bai
	$(PICARD_JAVA) $(PICARD_HOME)/MarkDuplicates.jar $(PICARD_OPTIONS) I=$< M=$@.tmp O=$(@:.dup_metrics=).dup.bam && mv $@.tmp $@

$(outdir)/%.align_metrics: %.bam %.bai
	$(PICARD_JAVA) $(PICARD_HOME)/CollectAlignmentSummaryMetrics.jar $(PICARD_OPTIONS) I=$< O=$@.tmp R=$(REFERENCE) && mv $@.tmp $@

$(outdir)/%.hs_metrics: %.bam %.bai
	$(PICARD_JAVA) $(PICARD_HOME)/CalculateHsMetrics.jar $(PICARD_OPTIONS) TI=$(PICARD_TARGET_REGIONS) BI=$(PICARD_BAIT_REGIONS) I=$< O=$@.tmp R=$(REFERENCE) && mv $@.tmp $@

# Shorthands
ifndef PICARD_DUPMETRICS_TARGETS
PICARD_DUPMETRICS_TARGETS=$(subst .bam,.dup_metrics,$(wildcard $(INPUTDIR)/*/*recal.bam))
endif
$(outdir)/dupmetrics: $(PICARD_DUPMETRICS_TARGETS)

ifndef PICARD_HSMETRICS_TARGETS
PICARD_HSMETRICS_TARGETS=$(subst .bam,.hs_metrics,$(wildcard $(INPUTDIR)/*/*recal.bam))
endif
$(outdir)/hsmetrics: $(PICARD_HSMETRICS_TARGETS)

ifndef PICARD_INSERTMETRICS_TARGETS
PICARD_INSERTMETRICS_TARGETS=$(subst .bam,.insert_metrics,$(wildcard $(INPUTDIR)/*/*recal.bam))
endif
$(outdir)/insertmetrics: $(PICARD_INSERTMETRICS_TARGETS)

ifndef PICARD_ALIGNMETRICS_TARGETS
PICARD_ALIGNMETRICS_TARGETS=$(subst .bam,.align_metrics,$(wildcard $(INPUTDIR)/*/*recal.bam))
endif
$(outdir)/alignmetrics: $(PICARD_ALIGNMETRICS_TARGETS)

$(outdir)/metrics: dupmetrics hsmetrics insertmetrics alignmetrics

# Summaries
# NB: these rules require scilife directory structure SAMPLE/FLOWCELL/SAMPLE.fastq
$(outdir)/align_metrics.txt: $(PICARD_ALIGNMETRICS_TARGETS)
	@for f in $(sort $(PICARD_ALIGNMETRICS_TARGETS)); do bn=$$(dirname $$f); fc=$$(basename $$bn); sampledir=$$(dirname $$bn); sample=$$(basename $$sampledir); $(AWK) -v SAMPLE=$$sample -v FLOWCELL=$$fc '{OFS="\t";if (NR==7) print $$0,"SAMPLE_ID","FLOWCELL", "INPUT_FILE"}' $$f; done | head -1 > $@.tmp;
	@for f in $(sort $(PICARD_ALIGNMETRICS_TARGETS)); do bn=$$(dirname $$f); fc=$$(basename $$bn); sampledir=$$(dirname $$bn); sample=$$(basename $$sampledir); $(AWK) -v SAMPLE=$$sample -v FLOWCELL=$$fc -v INPUT_FILE=$$f -v BN=$$(basename $$f) '{OFS="\t"; if (match(BN, SAMPLE)==0 || SAMPLE==".") {SAMPLE = FLOWCELL; FLOWCELL="NA"}  if (NR==8 || NR==9 || NR==10) print $$0,SAMPLE,FLOWCELL,INPUT_FILE}' $$f; done >> $@.tmp && mv $@.tmp $@;

$(outdir)/dup_metrics.txt: $(PICARD_DUPMETRICS_TARGETS)
	@for f in $(sort $(PICARD_DUPMETRICS_TARGETS)); do bn=$$(dirname $$f); fc=$$(basename $$bn); sampledir=$$(dirname $$bn); sample=$$(basename $$sampledir); $(AWK) -v SAMPLE=$$sample -v FLOWCELL=$$fc '{OFS="\t";if (NR==7) print $$0,"SAMPLE_ID","FLOWCELL", "INPUT_FILE"}' $$f; done | head -1 > $@.tmp;
	@for f in $(sort $(PICARD_DUPMETRICS_TARGETS)); do bn=$$(dirname $$f); fc=$$(basename $$bn); sampledir=$$(dirname $$bn); sample=$$(basename $$sampledir); $(AWK) -v SAMPLE=$$sample -v FLOWCELL=$$fc -v INPUT_FILE=$$f -v BN=$$(basename $$f) '{OFS="\t";  if (match(BN, SAMPLE)==0 || SAMPLE==".") {SAMPLE = FLOWCELL; FLOWCELL="NA"} if (NR==8) print $$0,SAMPLE,FLOWCELL,INPUT_FILE}' $$f; done >> $@.tmp && mv $@.tmp $@;

$(outdir)/insert_metrics.txt: $(PICARD_INSERTMETRICS_TARGETS)
	@for f in $(sort $(PICARD_INSERTMETRICS_TARGETS)); do bn=$$(dirname $$f); fc=$$(basename $$bn); sampledir=$$(dirname $$bn); sample=$$(basename $$sampledir); $(AWK) -v SAMPLE=$$sample -v FLOWCELL=$$fc '{OFS="\t";if (NR==7) print $$0,"SAMPLE_ID","FLOWCELL", "INPUT_FILE"}' $$f; done | head -1 > $@.tmp;
	@for f in $(sort $(PICARD_INSERTMETRICS_TARGETS)); do bn=$$(dirname $$f); fc=$$(basename $$bn); sampledir=$$(dirname $$bn); sample=$$(basename $$sampledir); $(AWK) -v SAMPLE=$$sample -v FLOWCELL=$$fc -v INPUT_FILE=$$f -v BN=$$(basename $$f) '{OFS="\t"; if (match(BN, SAMPLE)==0 || SAMPLE==".") {SAMPLE = FLOWCELL; FLOWCELL="NA"} if (NR==8) print $$0,SAMPLE,FLOWCELL,INPUT_FILE}' $$f; done >> $@.tmp && mv $@.tmp $@;

$(outdir)/hs_metrics.txt: $(PICARD_HSMETRICS_TARGETS)
	@for f in $(sort $(PICARD_HSMETRICS_TARGETS)); do bn=$$(dirname $$f); fc=$$(basename $$bn); sampledir=$$(dirname $$bn); sample=$$(basename $$sampledir); $(AWK) -v SAMPLE=$$sample -v FLOWCELL=$$fc '{OFS="\t";if (NR==7) print $$0,"SAMPLE_ID","FLOWCELL", "INPUT_FILE"}' $$f; done | head -1 > $@.tmp;
	@for f in $(sort $(PICARD_HSMETRICS_TARGETS)); do bn=$$(dirname $$f); fc=$$(basename $$bn); sampledir=$$(dirname $$bn); sample=$$(basename $$sampledir); $(AWK) -v SAMPLE=$$sample -v FLOWCELL=$$fc -v INPUT_FILE=$$f -v BN=$$(basename $$f) '{OFS="\t"; if (match(BN, SAMPLE)==0 || SAMPLE==".") {SAMPLE = FLOWCELL; FLOWCELL="NA"} if (NR==8) print $$0,SAMPLE,FLOWCELL,INPUT_FILE}' $$f; done >> $@.tmp && mv $@.tmp $@;

$(outdir)/metrics.txt: align_metrics.txt dup_metrics.txt insert_metrics.txt hs_metrics.txt

# Simple metrics plot functions
ifndef PLOTMETRICS
PLOTMETRICS=$(MAKEDIR)scripts/plotMetrics.R
endif
$(outdir)/%_metrics.pdf: %_metrics.txt
	$(PLOTMETRICS) $< $@.tmp $* && mv $@.tmp $@


# Add read group information
$(outdir)/%.rg.bam: %.bam
	java -Xmx2g -jar $(PICARD_HOME)/AddOrReplaceReadGroups.jar INPUT=$< OUTPUT=$@.tmp SORT_ORDER=coordinate \
	RGID=$(firstword $(subst ., ,$*)) RGLB=lib RGPL=ILLUMINA RGPU=$(firstword $(subst ., ,$*)) \
	RGSM=$(firstword $(subst /, ,$(firstword $(subst ., ,$*)))) CREATE_INDEX=true && mv $@.tmp $@; mv $@.tmp.bai $(@.bam=).bai

##############################
# Merging
# Difficult to write generic rules
##############################
ifndef PICARD_MERGESAM_OPTIONS
PICARD_MERGESAM_OPTIONS=CREATE_INDEX=true
endif
ifndef PICARD_MERGESAM_TARGETS
PICARD_MERGESAM_TARGETS=
endif

$(outdir)/%.merge.bam: 
	@$(eval INPUTFILES=$(addprefix INPUT=,$(filter $(dir $*)%, $(PICARD_MERGESAM_TARGETS))))
	$(PICARD_JAVA) $(PICARD_HOME)/MergeSamFiles.jar $(INPUTFILES) O=$@.tmp $(PICARD_OPTIONS_COMMON) $(PICARD_MERGESAM_OPTION) && mv $@.tmp $@ && mv $@.tmp.bai $(@:.bam=).bai

##############################
# settings
##############################
.PHONY: picard-settings picard-header

print-%:
	@echo '$*=$($*)'

picard-header:
	@echo -e "\npicard.mk options"
	@echo "======================="

picard-settings: picard-header print-PICARD_HOME print-PICARD_JAVA_MEM print-PICARD_JAVA_TMPDIR print-PICARD_JAVA print-REFERENCE print-PICARD_TARGET_REGIONS print-PICARD_BAIT_REGIONS print-PICARD_OPTIONS_COMMON print-PICARD_ALIGNMETRICS_TARGETS print-PICARD_DUPMETRICS_TARGETS print-PICARD_HSMETRICS_TARGETS print-PICARD_INSERTMETRICS_TARGETS print-PLOTMETRICS print-PICARD_SORTSAM_OPTIONS print-PICARD_MERGESAM_OPTIONS print-PICARD_MERGESAM_TARGETS
