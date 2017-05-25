outdir ?= .

$(outdir)/%.vcf.gz: %.vcf
	bgzip -c $< > $@ \
	&& tabix -p vcf $@
