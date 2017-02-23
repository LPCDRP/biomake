
%.vcf.gz %.vcf.gz.tbi: %.vcf
	bgzip -c $< > $<.gz \
	&& tabix -p vcf $<.gz
