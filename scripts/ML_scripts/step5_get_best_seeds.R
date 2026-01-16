## Get best seeds from array run
## Author: Andrew Oliver
## Date: January 15, 2026

################################################################################
############################ General Parameters ################################
################################################################################

# bind mount to /quobyte/dglemaygrp/aoliver/ml_paper/

IR_input_path <- "/home/rstudio/ir_run_12052025/raw_data/"
IR_output_path <- "/home/rstudio/ir_run_12052025/"
POLY_input_path <- "/home/rstudio/poly_run_010252026/raw_data/"
POLY_output_path <- "/home/rstudio/poly_run_010252026/"

## load libraries
library(dplyr)
library(vroom)
library(readr)
library(tidyr)
library(janitor)

################################################################################
######################## Insulin Resistance Dataset ############################
################################################################################

setwd(IR_output_path)

## inital scores
results <- readr::read_csv("ir_scores.csv") %>% janitor::clean_names()
results$score_origin <- gsub(pattern = "_taxahfe,", ",", x = results$score_origin)
results <- results %>% 
  tidyr::separate(., col = score_origin, into = c("score_origin", "method"), sep = ",", extra = "merge") %>%
  dplyr::filter(., !grepl("shap", method)) %>%
  dplyr::select(., -growth_metric)
results <- results %>% janitor::clean_names() %>%
  distinct()

## best seeds of those scores for each dataset/method
best_seeds <- results %>% 
  dplyr::filter(., metric == "bal_accuracy") %>%
  dplyr::group_by(., method, score_origin) %>%
  dplyr::arrange(., desc(estimate)) %>%
  dplyr::slice_head(n = 1)

## subset the inital commands for just the best seeds
ir_array_cmds <- readr::read_lines("array_cmds.txt")
best_seeds_cmds <- list()
for (row in 1:nrow(best_seeds)) {
  tmp_best_cmd <- grep(pattern = best_seeds[row,]$score_origin, x = ir_array_cmds, value = T)
  tmp_best_cmd <- grep(pattern = best_seeds[row,]$method, x = tmp_best_cmd, value = T)
  tmp_best_cmd <- grep(pattern = best_seeds[row,]$seed, x = tmp_best_cmd, value = T)
  if (grepl("diet",best_seeds[row,]$method)) {
    tmp_best_cmd <- gsub(pattern = "--seed", replacement = "--shap TRUE --seed", x = tmp_best_cmd)
  } else {
    tmp_best_cmd <- gsub(pattern = "--seed", replacement = "--shap --seed", x = tmp_best_cmd)
  }
  best_seeds_cmds <- append(x = best_seeds_cmds, values = tmp_best_cmd)
}
readr::write_lines(file = "best_seed_cmds.txt", x = unlist(best_seeds_cmds), append = FALSE)


################################################################################
############################ Polyphenol Dataset ################################
################################################################################

setwd(POLY_output_path)

## inital scores
results <- readr::read_csv("poly_scores.csv") %>% janitor::clean_names()
results$score_origin <- gsub(pattern = "_taxahfe,", ",", x = results$score_origin)
results <- results %>% 
  tidyr::separate(., col = score_origin, into = c("score_origin", "method"), sep = ",", extra = "merge") %>%
  dplyr::filter(., !grepl("shap", method)) %>%
  dplyr::select(., -growth_metric)
results <- results %>% janitor::clean_names() %>%
  distinct()

## best seeds of those scores for each dataset/method
best_seeds <- results %>% 
  dplyr::filter(., metric == "mae") %>%
  dplyr::group_by(., method, score_origin) %>%
  dplyr::arrange(., estimate) %>%
  dplyr::slice_head(n = 1)

## subset the inital commands for just the best seeds
poly_array_cmds <- readr::read_lines("array_cmds.txt")
best_seeds_cmds <- list()
for (row in 1:nrow(best_seeds)) {
  tmp_best_cmd <- grep(pattern = best_seeds[row,]$score_origin, x = poly_array_cmds, value = T)
  tmp_best_cmd <- grep(pattern = best_seeds[row,]$method, x = tmp_best_cmd, value = T)
  tmp_best_cmd <- grep(pattern = best_seeds[row,]$seed, x = tmp_best_cmd, value = T)
  if (grepl("diet",best_seeds[row,]$method)) {
    tmp_best_cmd <- gsub(pattern = "--seed", replacement = "--shap TRUE --seed", x = tmp_best_cmd)
  } else {
    tmp_best_cmd <- gsub(pattern = "--seed", replacement = "--shap --seed", x = tmp_best_cmd)
  }
  best_seeds_cmds <- append(x = best_seeds_cmds, values = tmp_best_cmd)
}
readr::write_lines(file = "best_seed_cmds.txt", x = unlist(best_seeds_cmds), append = FALSE)
