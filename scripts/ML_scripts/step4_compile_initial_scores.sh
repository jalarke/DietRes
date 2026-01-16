#!/bin/bash

## Get results from runs
## Author: Andrew Oliver
## Date: January 15, 2026

# variables
IR_WORKDIR=/quobyte/dglemaygrp/aoliver/ml_paper/ir_run_12052025/
POLY_WORKDIR=/quobyte/dglemaygrp/aoliver/ml_paper/poly_run_010252026/
  
## start with IR
cd ${IR_WORKDIR}

## find all the results for IR

for f in ir*/output_*/dietml_*/ml_results.csv; do
g=$(echo $f | awk -F'/' '{print $1}');
i=$(echo $f | awk -F"/" '{print $3}' )
h=$(awk -F',' -v OFS=',' -v var="$g" -v prog="$i" 'NR>1 {print $0,"NA",var,prog}' $f | head -n 5);
echo $h | sed "s/ /\n/g" ; done > ir_dietml_scores.csv

echo "metric,estimator,estimate,config,null_model_avg,seed,program,growth_metric,score_origin" | cat - ir_dietml_scores.csv > ir_dietml_scores.csv1
rm ir_dietml_scores.csv
mv ir_dietml_scores.csv1 ir_dietml_scores.csv

for f in ir*/output_*/taxahfe*/ml_analysis/ml_results.csv; do 
g=$(echo $f | awk -F'/' '{print $1}'); 
i=$(echo $f | awk -F"/" '{print $3}' )
h=$(awk -F',' -v OFS=',' -v var="$g" -v prog="$i" 'NR>1 {print $0,"NA",var,prog}' $f | head -n 5); 
echo $h | sed "s/ /\n/g" ; done > ir_taxahfe_scores.csv

for f in ir*/output_*/taxahfe_sf*/ml_analysis/ml_results.csv; do 
g=$(echo $f | awk -F'/' '{print $1}'); 
i=$(echo $f | awk -F"/" '{print $3}' )
h=$(awk -F',' -v OFS=',' -v var="$g" -v prog="$i" 'NR>1 {print $0,"NA",var,prog}' $f | head -n 5); 
echo $h | sed "s/ /\n/g" ; done > ir_taxahfe_sf_scores.csv

cat ir_dietml_scores.csv ir_taxahfe_scores.csv ir_taxahfe_sf_scores.csv > ir_scores.csv
rm ir_dietml_scores.csv ir_taxahfe_scores.csv ir_taxahfe_sf_scores.csv

## also for poly
cd ${POLY_WORKDIR}

## find all the results for IR
for f in poly*/output_*/dietml_*/ml_results.csv; do
g=$(echo $f | awk -F'/' '{print $1}');
i=$(echo $f | awk -F"/" '{print $3}' )
h=$(awk -F',' -v OFS=',' -v var="$g" -v prog="$i" 'NR>1 {print $0,"NA",var,prog}' $f | head -n 5);
echo $h | sed "s/ /\n/g" ; done > poly_dietml_scores.csv

echo "metric,estimator,estimate,config,null_model_avg,seed,program,growth_metric,score_origin" | cat - poly_dietml_scores.csv > poly_dietml_scores.csv1
rm poly_dietml_scores.csv
mv poly_dietml_scores.csv1 poly_dietml_scores.csv

for f in poly*/output_*/taxahfe*/ml_analysis/ml_results.csv; do 
g=$(echo $f | awk -F'/' '{print $1}'); 
i=$(echo $f | awk -F"/" '{print $3}' )
h=$(awk -F',' -v OFS=',' -v var="$g" -v prog="$i" 'NR>1 {print $0,"NA",var,prog}' $f | head -n 5); 
echo $h | sed "s/ /\n/g" ; done > poly_taxahfe_scores.csv

for f in poly*/output_*/taxahfe_sf*/ml_analysis/ml_results.csv; do 
g=$(echo $f | awk -F'/' '{print $1}'); 
i=$(echo $f | awk -F"/" '{print $3}' )
h=$(awk -F',' -v OFS=',' -v var="$g" -v prog="$i" 'NR>1 {print $0,"NA",var,prog}' $f | head -n 5); 
echo $h | sed "s/ /\n/g" ; done > poly_taxahfe_sf_scores.csv

cat poly_dietml_scores.csv poly_taxahfe_scores.csv poly_taxahfe_sf_scores.csv > poly_scores.csv
rm poly_dietml_scores.csv poly_taxahfe_scores.csv poly_taxahfe_sf_scores.csv
