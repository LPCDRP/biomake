outdir ?= .

include samtools.mk

define PBHONEY_USAGE
The following variables must be set:
INPUT	input reads
REFERENCE	the reference sequence to align reads to

endef

ifndef INPUT
$(error $(PBHONEY_USAGE))
endif

ifndef REFERENCE
$(error $(PBHONEY_USAGE))
endif

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

$(outdir)/%.hon.tails: $(addprefix %.tails,.bam .bam.bai)
	Honey.py tails $(TAILSFLAGS) $< -o $@

$(outdir)/%.unsorted.sam: $(INPUT) $(REFERENCE)
	Honey.py pie $(PIEFLAGS) $< $(word 2,$^) -o $@
