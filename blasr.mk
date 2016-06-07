
BLASR ?= blasr

ifneq ($(NPROC),)
BLASRFLAGS += -nproc $(NPROC)
endif

ifdef BLASR_CONCORDANT
BLASRFLAGS += -concordant
endif

ifdef BLASR_IGNOREREGIONS
BLASRFLAGS += -ignoreRegions
endif

ifdef BLASR_USEQUALITY
BLASRFLAGS += -useQuality
endif

ifdef BLASR_RANDOMSEED
BLASRFLAGS += -randomSeed $(BLASR_RANDOMSEED)
endif

ifdef BLASR_BESTN
BLASRFLAGS += -bestn $(BLASR_BESTN)
endif

ifdef BLASR_MINPCTIDENTITY
BLASRFLAGS += -minPctIdentity $(BLASR_MINPCTIDENTITY)
endif

ifdef BLASR_MINMATCH
BLASRFLAGS += -minMatch $(BLASR_MINMATCH)
endif

ifdef BLASR_PLACEREPEATSRANDOMLY
BLASRFLAGS += -placeRepeatsRandomly
endif

ifdef BLASR_HITPOLICY
BLASRFLAGS += -hitPolicy $(BLASR_HITPOLICY)
endif

ifdef BLASR_MINPCTACCURACY
BLASRFLAGS += -minPctAccuracy $(BLASR_MINPCTACCURACY)
endif

ifdef BLASR_MINSUBREADLENGTH
BLASRFLAGS += -minSubreadLength $(BLASR_MINSUBREADLENGTH)
endif

ifdef BLASR_MINREADLENGTH
BLASRFLAGS += -minReadLength $(BLASR_MINREADLENGTH)
endif

# These options require or create additional files

ifdef BLASR_REGIONTABLE
BLASRFLAGS += -regionTable $(BLASR_REGIONTABLE)
%.sam: $(BLASR_REGIONTABLE)
endif

ifdef BLASR_UNALIGNEDFILE
BLASRFLAGS += -unaligned $(BLASR_UNALIGNEDFILE)
endif


.SECONDEXPANSION:
%.sam: $(BLASR_INPUT) $$(REFERENCE)
	$(BLASR) $< $(word 2,$^) -sam -out $@ $(BLASRFLAGS)
