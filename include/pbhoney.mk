outdir ?= .

include samtools.mk

# Set the inputReads and reference -- change at your leisure
# inputReads ?= corrected.fastq
# reference ?= final.fasta

NPROC ?= $(shell nproc)

# Buffer around breaks reads must fall within to become clustered
ifdef TAILS_BUFFER
TAILS_FLAGS += --buffer $(TAILS_BUFFER)
endif

# Minimum number of reads
ifdef TAILS_MINBREADS
TAILS_FLAGS += --minBreads $(TAILS_MINBREADS)
endif

# Minimum number of unique ZMWs
ifdef TAILS_MINZMWS
TAILS_FLAGS += --minZMWs $(TAILS_MINZMWS)
endif

# Minimum mapping quality of a read and its tail to consider
ifdef TAILS_MINMAPQ
TAILSFLAGS += --minMapq $(TAILS_MINMAPQ)
endif

PIEFLAGS += --nproc $(NPROC)

$(outdir)/%.hon.tails: $(addprefix %.tails,.sort.bam .sort.bam.bai)
	Honey.py tails $(TAILSFLAGS) $< -o $@  2>&1 | tee tails.log

$(outdir)/%.sam: $(inputReads) $(REF)
	Honey.py pie $(PIEFLAGS) $< $(word 2,$^) -o $@ 2>&1 | tee pie.log
