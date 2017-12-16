SHELL := /bin/bash


MAGEROOT=
MAGE_PROJECTDIR=$$HOME/mage-user
KALLISTO=$$HOME/bin/kallisto_linux-v0.43.0/kallisto
KALLISTO_INDEX=
META=
QUANT_OUTPUTDIR=
GTF=config_files/Macaca_mulatta.Mmul_8.0.1.90.gtf 
REF=~/S/projSST/data/interim/reference_selection/Macaca_mulatta.Mmul_8.0.1.cdna.all.kallisto_v0.43.0.idx

help: ## Prints help for targets with comments
	@grep -E '^[.0-9a-zA-Z_-/]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# TODO needs to fix this
quant: ## Quantification process
	bin/mage-quant -kal=$(KALLISTO) -fastqdir=$(MAGE_PROJECTDIR)/fastqs -index=$(KALLISTO_INDEX) -meta=$(META) -outputdir=$(QUANT_OUTPUTDIR)
	Rscript $(MAGEROOT)/src/utils/gtf_to_mapping.R ref/Macaca_mulatta.Mmul_8.0.1.90.gtf > t2g_mapping.tsv
	Rscript $(MAGEROOT)/src/quant/convert_t2g.R exprs_transcript.tsv t2g_mapping.tsv > EM_gene.tsv
	Rscript $(MAGEROOT)/src/utils/stat_expression_matrix.R exprs_gene.tsv > stat.json
	Rscript $(MAGEROOT)/src/utils/prepare_and_clean_exprs.R exprs_gene.tsv stat.json > exprs_gene_clean_long.ts


all: config_files/transcript_to_gene_mapping.tsv config_files/expression_matrix_transcript.tsv


config_files/transcript_to_gene_mapping.tsv: ## Transcript to Gene Mapping file
	Rscript src/utils/gtf_to_mapping.R $(GTF) > config_files/transcript_to_gene_mapping.tsv


config_files/expression_matrix_transcript.tsv: ## Expression matrix - transcript-level
	Rscript merge_abundances.R $(REF) > config_files/expression_matrix_transcript.tsv

config_files/expression_matrix_gene.tsv: config_files/expression_matrix_transcript.tsv ## Expression matrix - gene level
	Rscript src/quant/convert_t2g.R config_files/expression_matrix_transcript.tsv config_files/transcript_to_gene_mapping.tsv > config_files/expression_matrix_gene.tsv

config_files/expression_matrix_stats.json: stat_expression_matrix.R config_files/expression_matrix_gene.tsv ## Expression matrix statistics / sample&gene filtering information JSON
	Rscript ~/S/projSST/scripts/mage_run/stat_expression_matrix.R config_files/expression_matrix_gene.tsv 0.6e6 > config_files/expression_matrix_stats.json

config_files/expression_matrix_long.tsv: config_files/expression_matrix_gene.tsv ## Expression matrix wide to long
	Rscript gather_expression_matrix.R config_files/expression_matrix_gene.tsv > config_files/expression_matrix_long.tsv
