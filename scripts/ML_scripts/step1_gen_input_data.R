## Create the ML and TaxaHFE inputs from the raw data
## Author: Andrew Oliver
## Date: January 15, 2026

################################################################################
############################ General Parameters ################################
################################################################################

# bind mount to /quobyte/dglemaygrp/aoliver/ml_paper/

IR_input_path <- "/home/rstudio/ir_run_12052025/raw_data/"
IR_output_path <- "/home/rstudio/ir_run_test/"
POLY_input_path <- "/home/rstudio/poly_run_010252026/raw_data/"
POLY_output_path <- "/home/rstudio/poly_run_test/"

## Define resources
CORES_avail <- 8

## load libraries
library(dplyr)
library(vroom)
library(readr)
library(tidyr)
library(janitor)

################################################################################
######################## Insulin Resistance Dataset ############################
################################################################################

setwd(IR_input_path)

# read in metadata for dietML
ir_metadata <- vroom::vroom("ir_target.tsv", delim = "\t", num_threads = CORES_avail) %>%
  dplyr::mutate(., ir = ifelse(ir == "no", "low", "high")) %>% 
  janitor::clean_names() %>%
  tidyr::drop_na()

# read in predictor datasets
ingred_all <- vroom::vroom("wweia_ingredients_wide.tsv", delim = "\t", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  tidyr::drop_na()
mixed_meals <- vroom::vroom("wweia_mixed_meals_wide.tsv", delim = "\t", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  tidyr::drop_na()
nutrients <- vroom::vroom("wweia_nutrients_all_features.tsv", delim = "\t", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  tidyr::drop_na()
fped <- vroom::vroom("wweia_fped.tsv", delim = "\t", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  tidyr::drop_na()

# combine above datasets with metadata
ir_ingred_all <- merge(ir_metadata, ingred_all, by = "seqn")
ir_mixed_meals <- merge(ir_metadata, mixed_meals, by = "seqn")
ir_nutrients <- merge(ir_metadata, nutrients, by = "seqn")
ir_fped <- merge(ir_metadata, fped, by = "seqn")

# read in metadata for taxaHFE
ir_metadata_taxahfe <- vroom::vroom("metadata_ir.tsv", delim = "\t", num_threads = CORES_avail) %>%
  dplyr::mutate(., ir = ifelse(ir == "no", "low", "high")) %>% 
  janitor::clean_names() %>%
  tidyr::drop_na() %>% dplyr::filter(., seqn %in% ir_metadata$seqn)

# read in predictor data for taxaHFE
ingred_all_taxahfe <- vroom::vroom("ir_ingred_otu_table.txt", delim = "\t", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  tidyr::drop_na() %>%
  dplyr::select(., -clade_name) %>%
  dplyr::relocate(., taxonomy) %>%
  dplyr::rename(., "clade_name" = "taxonomy") %>%
  dplyr::mutate(., clade_name = gsub(";", "|", clade_name))
colnames(ingred_all_taxahfe) <- gsub("^x", "", colnames(ingred_all_taxahfe))

mixed_meals_taxahfe <- vroom::vroom("foodcode_otu_table.txt", delim = "\t", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  dplyr::mutate(., clade_name = stringr::str_to_snake(clade_name)) %>%
  dplyr::mutate(., clade_name_new = paste0(taxonomy, ";", clade_name)) %>%
  tidyr::drop_na() %>%
  dplyr::select(., -clade_name, -taxonomy) %>%
  dplyr::relocate(., clade_name_new) %>%
  dplyr::rename(., "clade_name" = "clade_name_new") %>%
  dplyr::mutate(., clade_name = gsub(";", "|", clade_name))
colnames(mixed_meals_taxahfe) <- gsub("^x", "", colnames(mixed_meals_taxahfe))

## subset based on metabolically at risk individuals
## wc >= 102 (males), >= 88 (females)
## bmi >= 25

dataset_list <- dplyr::lst(ir_ingred_all, ir_metadata_taxahfe, 
                           ir_mixed_meals, ir_nutrients, ir_fped)

covariates_to_remove <- c("bmi", "wc", "sex", "age", "ethnicity", "family_pir", "education", "hypertension", "met_risk")
for (i in 1:length(dataset_list)) {
  subsetted_data <- dataset_list[[i]] %>%
    dplyr::filter(., bmi >= 25) %>% 
    dplyr::filter(., ifelse(sex == "Male", wc >= 102, wc >= 88)) %>%
    dplyr::select(., -dplyr::any_of(covariates_to_remove))
  assign(paste0(names(dataset_list[i]), "_met_sub"), subsetted_data)
}

# write files for use
setwd(IR_output_path)
vroom::vroom_write(ir_ingred_all_met_sub, file = "ir_ingred_all_subsetted.tsv", delim = "\t", num_threads = CORES_avail)
vroom::vroom_write(ir_mixed_meals_met_sub, file = "ir_mixed_meals_subsetted.tsv", delim = "\t", num_threads = CORES_avail)
vroom::vroom_write(ir_nutrients_met_sub, file = "ir_nutrients_subsetted.tsv", delim = "\t", num_threads = CORES_avail)
vroom::vroom_write(ir_fped_met_sub, file = "ir_fped_subsetted.tsv", delim = "\t", num_threads = CORES_avail)
vroom::vroom_write(ir_metadata_taxahfe_met_sub, file = "ir_metadata_taxahfe_subsetted.tsv", delim = "\t", num_threads = CORES_avail)
vroom::vroom_write(mixed_meals_taxahfe, file = "mixed_meals.tsv", delim = "\t", num_threads = CORES_avail)
vroom::vroom_write(ingred_all_taxahfe, file = "ingred_all.tsv", delim = "\t", num_threads = CORES_avail)

################################################################################
########################## Polyphenol dataset ##################################
################################################################################


setwd(POLY_input_path)

# read in metadata for dietML
poly_wet_metadata <- vroom::vroom("polyphenol_wet_target_0930256_Update.tsv", delim = "\t", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  tidyr::drop_na()

# read in predictor datasets
ingred_all <- vroom::vroom("ingredients_for_polyphenols.tsv", delim = "\t", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  tidyr::drop_na()
nutrients <- vroom::vroom("total_nutrients_for_polyphenols.csv", delim = ",", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  tidyr::drop_na()
fped <- vroom::vroom("fped_for_polyphenols.csv", delim = ",", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  tidyr::drop_na()

# combine above datasets with metadata
poly_ingred_all <- merge(poly_wet_metadata, ingred_all, by = "seqn")
poly_nutrients <- merge(poly_wet_metadata, nutrients, by = "seqn")
poly_fped <- merge(poly_wet_metadata, fped, by = "seqn")

# read in data for taxahfe
ingred_all_taxahfe <- vroom::vroom("poly_ingred_otu_table.txt", delim = "\t", num_threads = CORES_avail) %>%
  janitor::clean_names() %>%
  tidyr::drop_na() %>%
  dplyr::select(., -clade_name) %>%
  dplyr::relocate(., taxonomy) %>%
  dplyr::rename(., "clade_name" = "taxonomy") %>%
  dplyr::mutate(., clade_name = gsub(";", "|", clade_name))
colnames(ingred_all_taxahfe) <- gsub("^x", "", colnames(ingred_all_taxahfe))

# write files for use
setwd(POLY_output_path)
vroom::vroom_write(poly_ingred_all, file = "poly_ingred_all.tsv", delim = "\t", num_threads = CORES_avail)
vroom::vroom_write(poly_nutrients, file = "poly_nutrients.tsv", delim = "\t", num_threads = CORES_avail)
vroom::vroom_write(poly_fped, file = "poly_fped.tsv", delim = "\t", num_threads = CORES_avail)
vroom::vroom_write(poly_wet_metadata, file = "poly_wet_metadata_taxahfe.tsv", delim = "\t", num_threads = CORES_avail)
vroom::vroom_write(ingred_all_taxahfe, file = "poly_all_ingred_taxahfe.tsv", delim = "\t", num_threads = CORES_avail)

################################################################################
############################ Generate Seeds ####################################
################################################################################

# seeds to iterate for IR data
setwd(IR_output_path)
set.seed(123456)
ir_random_seeds <- sample(1:10000000, size = 50)
readr::write_lines(ir_random_seeds, file = "ir_random_seeds.txt", num_threads = CORES_avail)

# seeds to iterate for Poly data
setwd(POLY_output_path)
set.seed(123456)
poly_random_seeds <- sample(1:10000000, size = 5)
readr::write_lines(poly_random_seeds, file = "poly_random_seeds.txt", num_threads = CORES_avail)

################################################################################
######################### Generate Dataset Lists ###############################
################################################################################

# data set list for IR
setwd(IR_output_path)
ir_diet_ml_list <- c("ir_ingred_all", "ir_mixed_meals", "ir_nutrients", "ir_fped")
ir_taxahfe_list <- c("mixed_meals", "ingred_all")
readr::write_lines(ir_diet_ml_list, file = "ir_dietml_datasets.txt", num_threads = CORES_avail)
readr::write_lines(ir_taxahfe_list, file = "ir_taxahfe_datasets.txt", num_threads = CORES_avail)


## data set list for POLY
setwd(POLY_output_path)
poly_diet_ml_list <- c("poly_ingred_all", "poly_nutrients", "poly_fped")
poly_taxahfe_list <- c("poly_all_ingred_taxahfe")
readr::write_lines(poly_diet_ml_list, file = "poly_dietml_datasets.txt", num_threads = CORES_avail)
readr::write_lines(poly_taxahfe_list, file = "poly_taxahfe_datasets.txt", num_threads = CORES_avail)
