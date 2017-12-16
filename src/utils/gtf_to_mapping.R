suppressPackageStartupMessages(library(tidyverse))
library(stringr)


args <- commandArgs(TRUE)
GTF_PATH <- args[1] # gtf file

df_gtf <- read_tsv(pipe(paste0("sed /^#/d < ", GTF_PATH)), col_names=c(
                "chr",
                "source",
                "feature",
                "start",
                "end",
                "dot",
                "strand",
                "dot2",
                "annotation"
                ),
            col_types=cols(
                chr = col_character(),
                source = col_character(),
                feature = col_character(),
                start = col_integer(),
                end = col_integer(),
                dot = col_character(),
                strand = col_character(),
                dot2 = col_character(),
                annotation = col_character()
                )
            )


# get 9th column
col_annotation <- df_gtf %>%
    filter(feature == "transcript" | feature == "CDS" ) %>%
    select(annotation)

extract_annotation <- function(annotation_string, annotation_element ) {
    str_match(annotation_string, paste0(annotation_element," \"(.*?)\""))[,2]
}

col_annotation %>%
    mutate(gene_id = extract_annotation(annotation,  "gene_id")) %>% 
    mutate(transcript_id = extract_annotation(annotation, "transcript_id")) %>%
    mutate(gene_name = extract_annotation(annotation, "gene_name")) %>%
    mutate(transcript_name = extract_annotation(annotation, "transcript_name")) %>%
    select(gene_id, transcript_id, gene_name, transcript_name) %>% 
    distinct() %>% 
    format_tsv() %>% 
    cat()
