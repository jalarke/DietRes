#!/bin/bash

## set the SLURM parameters for the job =================================
#SBATCH --job-name=ir_array_job
#SBATCH --output=/quobyte/dglemaygrp/aoliver/ml_paper/ir_run_test/std_err_out/ir_array_job_%A_%a.out
#SBATCH --error=/quobyte/dglemaygrp/aoliver/ml_paper/ir_run_test/std_err_out/ir_array_job_%A_%a.err
#SBATCH --partition=low # comment out this if you want to switch to spitfire cores
##SBATCH --partition=high
##SBATCH --account=dglemaygrp
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4g
#SBATCH --time=02:00:00
#SBATCH --array=1-800%50

## ======================================================================

# Pull one single line/filename from the list
# (In Awk, NR==x means where row# is x)
array_cmd=$( awk "NR==$SLURM_ARRAY_TASK_ID" /quobyte/dglemaygrp/aoliver/ml_paper/ir_run_test/array_cmds.txt )

# Run the array command found in file input to awk
# (first load any modules nessary)
module load apptainer/latest

bash -c "$array_cmd"