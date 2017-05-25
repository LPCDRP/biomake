$(outdir)/outdir ?= .
.DELETE_ON_ERROR:

VEP ?= variant_effect_predictor.pl

VEPFLAGS ?= --force_overwrite

ifdef VEP_DIR
VEPFLAGS += --dir $(VEP_DIR)
endif

ifdef VEP_SYNONYMS
VEPFLAGS += --synonyms $(VEP_SYNONYMS)
endif

ifdef VEP_OFFLINE
VEPFLAGS += --offline
endif

ifdef VEP_CACHE
VEPFLAGS += --cache
endif

ifdef VEP_CACHEVERSION
VEPFLAGS += --cache_version $(VEP_CACHEVERSION)
endif

ifdef VEP_FORMAT
VEPFLAGS += --format $(VEP_FORMAT)
endif

ifdef VEP_SPECIES
VEPFLAGS += --species $(VEP_SPECIES)
endif

ifdef VEP_SYMBOL
VEPFLAGS += --symbol
endif

ifdef VEP_VARIANTCLASS
VEPFLAGS += --variant_class
endif

ifdef VEP_FLAGPICK
VEPFLAGS += --flag_pick
endif

ifdef VEP_EVERYTHING
VEPFLAGS += --everything
endif

$(outdir)/%.annotated.vcf: VEPFLAGS += --vcf
$(outdir)/%.vep $(outdir)/%.annotated.vcf: %.vcf
	$(VEP) $(VEPFLAGS) -i $< -o $@
