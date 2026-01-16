#!/bin/bash -e

# variables
DIETML_SINGULARITY=/quobyte/dglemaygrp/aoliver/software/diet_ml_dev2026.sif
TAXAHFE_SINGULARITY=/quobyte/dglemaygrp/aoliver/software/taxahfe_ml_dev2026.sif
IR_WORKDIR=/quobyte/dglemaygrp/aoliver/ml_paper/ir_run_test/
POLY_WORKDIR=/quobyte/dglemaygrp/aoliver/ml_paper/poly_run_test/

## start with IR
cd ${IR_WORKDIR}

mkdir -p ${IR_WORKDIR}apptainer_temp/
mkdir -p ${IR_WORKDIR}std_err_out/

echo "Making IR DietML cmds..."
while read DIETML_DATASET; do
    while read SEED; do
    # dietML cor = 80
    echo "mkdir -p ${IR_WORKDIR}${DIETML_DATASET}/output_${SEED}/dietml_80 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${IR_WORKDIR}apptainer_temp/) --bind ${IR_WORKDIR}:/data ${DIETML_SINGULARITY} ${DIETML_DATASET}_subsetted.tsv -o /data/${DIETML_DATASET}/output_${SEED}/dietml_80/ -s seqn -t factor --parallel_workers 4 --cv_repeats 1 --model rf -l ir -n 4 --metric bal_accuracy -c 0.80 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --seed ${SEED}" >> ${IR_WORKDIR}array_cmds.txt
    # dietML cor = 95
    echo "mkdir -p ${IR_WORKDIR}${DIETML_DATASET}/output_${SEED}/dietml_95 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${IR_WORKDIR}apptainer_temp/) --bind ${IR_WORKDIR}:/data ${DIETML_SINGULARITY} ${DIETML_DATASET}_subsetted.tsv -o /data/${DIETML_DATASET}/output_${SEED}/dietml_95/ -s seqn -t factor --parallel_workers 4 --cv_repeats 1 --model rf -l ir -n 4 --metric bal_accuracy -c 0.95 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --seed ${SEED}" >> ${IR_WORKDIR}array_cmds.txt
    done < ${IR_WORKDIR}ir_random_seeds.txt
done < ${IR_WORKDIR}ir_dietml_datasets.txt

echo "Making IR TaxaHFE cmds..."
while read TAXAHFE_DATASET; do
    while read SEED; do
    ## taxaHFE (no-sf), cor = 80
    echo "mkdir -p ${IR_WORKDIR}ir_${TAXAHFE_DATASET}/output_${SEED}/taxahfe_80 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${IR_WORKDIR}apptainer_temp/) --bind ${IR_WORKDIR}:/data ${TAXAHFE_SINGULARITY} ir_metadata_taxahfe_subsetted.tsv ${TAXAHFE_DATASET}.tsv -o /data/ir_${TAXAHFE_DATASET}/output_${SEED}/taxahfe_80/ -s seqn -t factor -L 3 --parallel_workers 4 --cv_repeats 1 --model rf -l ir -n 4 --metric bal_accuracy -p 0.01 -c 0.80 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --nperm 40 -d --seed ${SEED}" >> ${IR_WORKDIR}array_cmds.txt
    ## taxaHFE (no-sf), cor = 95
    echo "mkdir -p ${IR_WORKDIR}ir_${TAXAHFE_DATASET}/output_${SEED}/taxahfe_95 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${IR_WORKDIR}apptainer_temp/) --bind ${IR_WORKDIR}:/data ${TAXAHFE_SINGULARITY} ir_metadata_taxahfe_subsetted.tsv ${TAXAHFE_DATASET}.tsv -o /data/ir_${TAXAHFE_DATASET}/output_${SEED}/taxahfe_95/ -s seqn -t factor -L 3 --parallel_workers 4 --cv_repeats 1 --model rf -l ir -n 4 --metric bal_accuracy -p 0.01 -c 0.95 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --nperm 40 -d --seed ${SEED}" >> ${IR_WORKDIR}array_cmds.txt
    ## taxaHFE (+sf), cor = 80
    echo "mkdir -p ${IR_WORKDIR}ir_${TAXAHFE_DATASET}/output_${SEED}/taxahfe_sf_80 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${IR_WORKDIR}apptainer_temp/) --bind ${IR_WORKDIR}:/data ${TAXAHFE_SINGULARITY} ir_metadata_taxahfe_subsetted.tsv ${TAXAHFE_DATASET}.tsv -o /data/ir_${TAXAHFE_DATASET}/output_${SEED}/taxahfe_sf_80/ -s seqn -t factor -L 3 --parallel_workers 4 --cv_repeats 1 --model rf -l ir -n 4 --metric bal_accuracy -p 0.01 -c 0.80 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --nperm 40 --seed ${SEED}" >> ${IR_WORKDIR}array_cmds.txt
    ## taxaHFE (+sf), cor = 95
    echo "mkdir -p ${IR_WORKDIR}ir_${TAXAHFE_DATASET}/output_${SEED}/taxahfe_sf_95 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${IR_WORKDIR}apptainer_temp/) --bind ${IR_WORKDIR}:/data ${TAXAHFE_SINGULARITY} ir_metadata_taxahfe_subsetted.tsv ${TAXAHFE_DATASET}.tsv -o /data/ir_${TAXAHFE_DATASET}/output_${SEED}/taxahfe_sf_95/ -s seqn -t factor -L 3 --parallel_workers 4 --cv_repeats 1 --model rf -l ir -n 4 --metric bal_accuracy -p 0.01 -c 0.95 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --nperm 40 --seed ${SEED}" >> ${IR_WORKDIR}array_cmds.txt
    done < ${IR_WORKDIR}ir_random_seeds.txt
done < ${IR_WORKDIR}ir_taxahfe_datasets.txt

## now for Polyphenols
cd ${POLY_WORKDIR}

mkdir -p ${POLY_WORKDIR}apptainer_temp/
mkdir -p ${POLY_WORKDIR}std_err_out/

echo "Making Poly DietML cmds..."
while read DIETML_DATASET; do
    while read SEED; do
    # dietML, cor = 80
    echo "mkdir -p ${POLY_WORKDIR}${DIETML_DATASET}/output_${SEED}/dietml_80 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${POLY_WORKDIR}apptainer_temp/) --bind ${POLY_WORKDIR}:/data ${DIETML_SINGULARITY} ${DIETML_DATASET}.tsv -o /data/${DIETML_DATASET}/output_${SEED}/dietml_80/ -s seqn -t numeric --parallel_workers 4 --cv_repeats 1 --model rf -l totalpp_mg1000kcal -n 4 --metric mae -c 0.80 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --seed ${SEED}" >> ${POLY_WORKDIR}array_cmds.txt
    # dietML, cor = 95
    echo "mkdir -p ${POLY_WORKDIR}${DIETML_DATASET}/output_${SEED}/dietml_95 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${POLY_WORKDIR}apptainer_temp/) --bind ${POLY_WORKDIR}:/data ${DIETML_SINGULARITY} ${DIETML_DATASET}.tsv -o /data/${DIETML_DATASET}/output_${SEED}/dietml_95/ -s seqn -t numeric --parallel_workers 4 --cv_repeats 1 --model rf -l totalpp_mg1000kcal -n 4 --metric mae -c 0.95 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --seed ${SEED}" >> ${POLY_WORKDIR}array_cmds.txt
    done < ${POLY_WORKDIR}poly_random_seeds.txt
done < ${POLY_WORKDIR}poly_dietml_datasets.txt

echo "Making Poly TaxaHFE cmds..."
while read TAXAHFE_DATASET; do
    while read SEED; do
    ## taxaHFE (no-sf), cor = 80
    echo "mkdir -p ${POLY_WORKDIR}${TAXAHFE_DATASET}/output_${SEED}/taxahfe_80 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${POLY_WORKDIR}apptainer_temp/) --bind ${POLY_WORKDIR}:/data ${TAXAHFE_SINGULARITY} poly_wet_metadata_taxahfe.tsv ${TAXAHFE_DATASET}.tsv -o /data/${TAXAHFE_DATASET}/output_${SEED}/taxahfe_80/ -s seqn -t numeric -L 3 --parallel_workers 4 --cv_repeats 1 --model rf -l totalpp_mg1000kcal -n 4 --metric mae -p 0.01 -c 0.80 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --nperm 40 -d --seed ${SEED}" >> ${POLY_WORKDIR}array_cmds.txt
    ## taxaHFE (no-sf), cor = 95
    echo "mkdir -p ${POLY_WORKDIR}${TAXAHFE_DATASET}/output_${SEED}/taxahfe_95 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${POLY_WORKDIR}apptainer_temp/) --bind ${POLY_WORKDIR}:/data ${TAXAHFE_SINGULARITY} poly_wet_metadata_taxahfe.tsv ${TAXAHFE_DATASET}.tsv -o /data/${TAXAHFE_DATASET}/output_${SEED}/taxahfe_95/ -s seqn -t numeric -L 3 --parallel_workers 4 --cv_repeats 1 --model rf -l totalpp_mg1000kcal -n 4 --metric mae -p 0.01 -c 0.95 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --nperm 40 -d --seed ${SEED}" >> ${POLY_WORKDIR}array_cmds.txt
    ## taxaHFE (+sf), cor = 80
    echo "mkdir -p ${POLY_WORKDIR}${TAXAHFE_DATASET}/output_${SEED}/taxahfe_sf_80 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${POLY_WORKDIR}apptainer_temp/) --bind ${POLY_WORKDIR}:/data ${TAXAHFE_SINGULARITY} poly_wet_metadata_taxahfe.tsv ${TAXAHFE_DATASET}.tsv -o /data/${TAXAHFE_DATASET}/output_${SEED}/taxahfe_sf_80/ -s seqn -t numeric -L 3 --parallel_workers 4 --cv_repeats 1 --model rf -l totalpp_mg1000kcal -n 4 --metric mae -p 0.01 -c 0.80 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --nperm 40 --seed ${SEED}" >> ${POLY_WORKDIR}array_cmds.txt
    ## taxaHFE (+sf), cor = 95
    echo "mkdir -p ${POLY_WORKDIR}${TAXAHFE_DATASET}/output_${SEED}/taxahfe_sf_95 && apptainer run --cwd /app --no-home -C --workdir \$(mktemp -d -p ${POLY_WORKDIR}apptainer_temp/) --bind ${POLY_WORKDIR}:/data ${TAXAHFE_SINGULARITY} poly_wet_metadata_taxahfe.tsv ${TAXAHFE_DATASET}.tsv -o /data/${TAXAHFE_DATASET}/output_${SEED}/taxahfe_sf_95/ -s seqn -t numeric -L 3 --parallel_workers 4 --cv_repeats 1 --model rf -l totalpp_mg1000kcal -n 4 --metric mae -p 0.01 -c 0.95 --info_gain_n 0 --train_split 0.85 --tune_time 0 --folds 10 --nperm 40 --seed ${SEED}" >> ${POLY_WORKDIR}array_cmds.txt
    done < ${POLY_WORKDIR}poly_random_seeds.txt
done < ${POLY_WORKDIR}poly_taxahfe_datasets.txt