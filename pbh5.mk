space=
space+=
comma=,

# Sam to H5 Conversion

SAMTOH5 ?= samtoh5

ifdef SAMTOH5_SMRTTITLE
SAMTOH5FLAGS += -smrtTitle
endif

ifdef SAMTOH5_READTYPE
SAMTOH5FLAGS += -readType $(SAMTOH5_READTYPE)
endif

ifdef SAMTOH5_COPYQVS
SAMTOH5FLAGS += -copyQVs
endif

LOADPULSES ?= loadPulses

ifdef PBH5_METRICS
LOADPULSESFLAGS += -metrics $(subst $(space),$(comma),$(strip $(PBH5_METRICS)))
endif

LOADCHEMISTRY ?= loadChemistry.py

CMPH5TOOLS ?= cmph5tools.py

H5REPACK ?= h5repack


.SECONDEXPANSION:
%.cmp.h5: %.sam $$(REFERENCE)
	$(SAMTOH5) $^ $@ $(SAMTOH5FLAGS)

%.cmp.h5: %.bloated.cmp.h5 %.fofn
	$(H5REPACK) -f GZIP=1 $< $@
	$(LOADPULSES) $(word 2,$^)  $@ $(LOADPULSESFLAGS)
	$(LOADCHEMISTRY) $(word 2,$^) $@

%.bloated.cmp.h5: %.unsorted.cmp.h5
	$(CMPH5TOOLS) sort --deep $< --outFile $@


# Filtering

FILTERPLSH5 ?= filter_plsh5.py

ifdef FILTER_MINREADSCORE
PBH5_FILTERS += MinReadScore=$(FILTER_MINREADSCORE)
endif

ifdef FILTER_MINSUBREADLENGTH
PBH5_FILTERS += MinSRL=$(FILTER_MINSUBREADLENGTH)
endif

ifdef FILTER_MINREADLENGTH
PBH5_FILTERS += MinRL=$(FILTER_MINREADLENGTH)
endif

# More filters not currently captured:
# MaxRL MaxSRL ReadWhitelist Subsampling

ifneq ($(PBH5_FILTERS),)
FILTERPLSH5FLAGS += --filter='$(subst $(space),$(comma),$(strip $(PBH5_FILTERS)))'
# Encode the filter parameters into the regiontable's filename
PBH5_REGIONTABLE ?= filtered_regions.$(subst $(space),.,$(subst =,_,$(strip $(PBH5_FILTERS)))).fofn
endif


.SECONDARY: %.$(PBH5_REGIONTABLE)
%.filtered_regions.fofn %.$(PBH5_REGIONTABLE): %.fofn
	$(FILTERPLSH5) $(FILTERPLSH5FLAGS) $< \
	--outputFofn $@ \
	--outputDir $(basename $@)


# Input File Preparation

.INTERMEDIATE: %.fofn
%.fofn: %
	$(RM) $@
# Look only for bax.h5 files first.
# They coexist with at least one bas.h5 file, but if both types are included in
# the fofn, smrtanalysis tools will fail.
	find $< -name "*.bax.h5" -exec realpath '{}' \; >> $@
# If there are no bax.h5 files, all the data are in bas.h5 files
	test -s "$@" \
	|| find $< -name "*.bas.h5" -exec realpath '{}' \; >> $@
