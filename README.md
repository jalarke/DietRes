# DietRes

What resolution of dietary intake best captures the relationship with your outcome of interest? Here we provide a comprehensive machine learning framework for analyzing the relationship between dietary intake from 24-hr recalls across different levels of dietary resolutions to determine which best fits the prediction of insulin resistance and total polyphenol intake.

## Overview
This repository contains code for multi-resolution dietary intake analysis using the NHANES/WWEIA dietary intake from 2003-2023. The analysis examines 24-hr dietary recalls at four resolutions:

- Nutrients - Individual macro and micronutrients
- Food Groups (FPED) - Food Pattern Equivalents Database classifications
- Ingredients - Individual food ingredients
- Tree-based Ingredients - Hierarchical ingredient food trees

By analyzing diet at multiple resolutions, this workflow enables comprehensive modeling of how different dietary characteristics influence metabolic health outcomes using machine learning techniques.

## Features

- Multi-resolution dietary data processing and feature extraction
- Machine learning models for insulin resistance prediction
- Hierarchical feature engineering (TaxaHFE)
- Feature importance via SHAPley values
- Visualization of dietary patterns and model results

## Use and Requirements

### Prerequisites

- Anaconda or Miniconda
- Git
- R

### Installation
1. Clone the repository
```
git clone https://github.com/jalarke/DietRes.git
cd DietRes
```
2. Create the conda environment and activate the environment
```
conda env create -f environment.yml
conda activate DietRes
```
### Build the NHANES datasets
1. Navigate to the first scipt and launch jupyter lab
```
cd scripts/00/
jupyter lab
```
2. Run the notebooks in order from 00 to 02
- 00_generate_datasets.ipynb - download NHANES data and data cleaning
- 01_build_nhanes_wweia.ipynb - add person specific covariates and outcomes, further preprocessing steps
- 02_food_tree_taxonomy.ipynb - create the food tree taxonomy

Execute cells sequentially within each notebook using Shift + Enter or the "Run" button.

### Create food trees using the DietDiveR package
1. Install reqired packages
2. Navigate to `scripts/03` and open R
3. Run each code chunk sequentailly ...

### Machine learning analysis with TaxaHFE/ML
Hierarchical feature engineering and machine learning were performed using two programs developed in the Lemay Group: DietML and [TaxaHFE](https://github.com/aoliver44/taxaHFE). DietML is a machine learning workflow that leverages [TidyModels](https://www.tidymodels.org/), a set of machine learning packages implemented in the R programming language. 

For DietML, data was wrangled such that the input contained a column for 'subject identifier' (in the context of NHANES, SEQN), a column for the response of interest (either HOMA-IR or total polyphenol intake), and columns of dietary features (predictor variables). An example of this data can be found in ```ml_example_inputs/```

[TaxaHFE](https://github.com/aoliver44/taxaHFE) is a program which reduces input features by considering known hierarchical relationships between features. For example, consider 2 hierarchically related features:

```
FeatureA: GrandparentA | Parent A | Feature A
FeatureB: GrandparentA | Parent A | Feature B
```

TaxaHFE assesses whether knowing something about Feature A and Feature B is  potentially useful. Otherwise, TaxaHFE will prune them as features, and keep Parent A (thus reducing the feature set). In practice, TaxaHFE has been shown to [reduce the number of input features by an average of 90%, while increasing the accuracy of machine learning models](https://doi.org/10.1093/bioadv/vbad165). Examples of inputs for TaxaHFE can be found in ```ml_example_inputs/```.

#### DietML

1. To run DietML, download Docker (or on a managed HPC system, look for Apptainer or Singularity). Pull the latest version of the code:

```
## using docker
docker pull aoliver44/nutrition_tools:latest

## using singularity OR apptainer
singularity pull nutrition_tools.sif docker://aoliver44/nutrition_tools:latest
```

2. Run the the program using the example data:

```
## you previous cloned this repository
## git clone https://github.com/jalarke/DietRes.git && cd DietRes

## Predict HOMA-IR using DietML
cd ml_example_inputs/

docker run --rm -it --platform linux/amd64 -v `pwd`:/home/docker aoliver44/nutrition_tools:latest bash -c "dietML --subject_identifier seqn --type classification --model rf --cv_repeats 1 --label ir --ncores 4 --parallel_workers 1 --metric bal_accuracy --train_split 0.85 --cor_level 0.95 --tune_time 0 --seed 6327340 /home/docker/ir_nutrients_example.tsv /home/docker/example_outs_dietML/"
```

Let's break down what the above command is doing:

```docker run --rm -it --platform linux/amd64 -v `pwd`:/home/docker aoliver44/nutrition_tools:latest bash -c``` : This part is telling docker to run the appropriate container (nutrition_tools:latest) and run the command printed after ```bash -c```

```--subject_identifier seqn``` : The subject identifier column in your dataset (for NHANES this is usually SEQN). Spelling and case matter here! For all columns I used the R package ```janitor::clean_names()``` to make column names as nice as possible for any downstream ML processes.

```--type classification```: Since our label is a factor (high vs low), the ML problem is a classification one (as opposed to a regression problem)

```--model rf```: we are using a random forest

```--cv_repeats 1```: A little more abstract, but here we are telling the program to not repeat any cross validation (repeated cross validation). 

```--label ir```: the column in your data which contains the response variable

```--ncores 4```: This is how many cores you wish to throw at the random forest algorithm

```--parallel_workers 1```: These are parallel workers used for hyperparameter tuning. Since we are not hyperparameter tuning, we are not going to throw any more resources at this. Note, parallel workers are a MULTIPLIER to ncores. If ```--parallel_workers``` was set to 2, dietML would be using 8 cores (4 ncores * 2 parallel workers)

```--metric bal_accuracy```: The metric we want to use to assess the performance of the ML model. Balanced accuracy is a great metric to use for robustness against class imbalance.

```--train_split 0.85```: This tells dietML to use 85% of the data for training and 15% for testing.

```--cor_level 0.95```: We want to group closely (redundant) features together. Two or more features that are highly correlated may trick a ML model when deciding what feature to use. Splitting credit among highly correlated variables dilutes their importance.

```--tune_time 0```: This is telling dietML we are not spending any time hyperparameter tuning. While HP tuning can yeild improvements in model performance, often they are fairly minor bumps in accuracy. (But its always worth verifying this is true for your data if you have the time to check!)

```--seed 6327340```: Just a random number for a random seed

```/home/docker/ir_nutrients_example.tsv```: This is our input data! Since we mounted all our data to ```/home/docker``` (the ```-v``` command in the docker command), everything is based on that path

```/home/docker/example_outs_dietML/```: This is a directory we want created for our output files