#!/bin/bash

## set the SLURM parameters for the job =================================
#SBATCH --job-name=poly_array_job
#SBATCH --output=/quobyte/dglemaygrp/aoliver/ml_paper/poly_run_test/std_err_out/poly_array_job_%A_%a.out
#SBATCH --error=/quobyte/dglemaygrp/aoliver/ml_paper/poly_run_test/std_err_out/poly_array_job_%A_%a.err
#SBATCH --partition=low # comment out this if you want to switch to spitfire cores
##SBATCH --partition=high
##SBATCH --account=dglemaygrp
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4g
#SBATCH --time=06:00:00
#SBATCH --array=1-50%5

## ======================================================================

# Pull one single line/filename from the list
# (In Awk, NR==x means where row# is x)
array_cmd=$( awk "NR==$SLURM_ARRAY_TASK_ID" /quobyte/dglemaygrp/aoliver/ml_paper/poly_run_test/array_cmds.txt )

# Run the array command found in file input to awk
# (first load any modules nessary)
module load apptainer/latest

bash -c "$array_cmd"