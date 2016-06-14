
VARCALLER ?= variantCaller

VARCALLER_ALGORITHM ?= quiver

VARCALLERFLAGS += --algorithm $(VARCALLER_ALGORITHM)
VARCALLERFLAGS += --verbose

ifdef NPROC
VARCALLERFLAGS += -j $(NPROC)
endif

ifdef VARCALLER_MINCONFIDENCE
VARCALLERFLAGS += --minConfidence $(VARCALLER_MINCONFIDENCE)
endif

ifdef VARCALLER_MINCOVERAGE
VARCALLERFLAGS += --minCoverage $(VARCALLER_MINCOVERAGE)
endif

ifdef VARCALLER_COVERAGE
VARCALLERFLAGS += --coverage $(VARCALLER_COVERAGE)
endif

ifdef VARCALLER_MINMAPQV
VARCALLERFLAGS += --minMapQV $(VARCALLER_MINMAPQV)
endif

ifdef VARCALLER_DIPLOID
VARCALLERFLAGS += --diploid
endif

comma=,


.SECONDEXPANSION:
%.fasta %.fa %.fastq %.fq %.gff: %.cmp.h5 $$(REFERENCE) $$(REFERENCE).fai
	$(VARCALLER) $(VARCALLERFLAGS) $< \
	--referenceFilename $(word 2,$^) \
	-o '$@$(foreach ext,$(VARCALLER_EXTS),$*.$(ext)$(comma))'
