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
- 02a_build_ingredient_hierarchy.ipynb - create the food tree heirarchies for mixed meals and ingredients
- 02b_food_tree_taxonomy.ipynb - apply the food tree hierarchies to the IR and polyphenol datasets

Execute cells sequentially within each notebook using Shift + Enter or the "Run" button.

### Create food trees using the DietDiveR package
1. Clone the forked DietDiveR repository to the directory containing DietRes
2. Install reqired packages
3. Navigate to `scripts/03` and open R
4. Run each code chunk sequentailly ...

### Machine learning analysis with TaxaHFE/ML
(how does Andrew want people to access TaxaHFE)

Point people to https://github.com/aoliver44/taxaHFE

## Acknowledgements
We would like to thank Abigail Johnson and Rie Sadohara for their work on DietDiveR which is used in this analysis...


