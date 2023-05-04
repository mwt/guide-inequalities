# Code for "A User's Guide for Inference in Models Defined by Moment Inequalities"

**This code is not yet ready for public use.**

This repository contains the code for the paper "A User's Guide for Inference in Models Defined by Moment Inequalities" by Canay, Illanes, and Velez available [here](https://www.amilcarvelez.com/working_paper/guide_mi/).

## Structure

The code is organized into four folders:

* `data` contains fake data intended to be similar to the data used in the empirical application in the paper. The data is stored in several csv files. The file [`data/README.md`](data/README.md) contains a description of the data.
* `matlab` contains the code for the Matlab implementation of the algorithms. The file [`matlab/README.md`](matlab/README.md) contains a description of the Matlab code.
* `python` contains the code for the Python implementation of the algorithms. The file [`python/README.md`](python/README.md) contains a description of the Python code.
* `r` contains the code for the R implementation of the algorithms. The file [`r/README.md`](r/README.md) contains a description of the R code.

In each of the three code implementations, there is one script for each table in the paper. This script produces the output for the table. The scripts are named `table_1.m` (or `.py` or `.R`), `table_2.m`, etc. The scripts are self-contained and can be run independently of each other.

## Outputs

Each implementation produces outputs in a folder named `_results`. The results folder is not included in the repository. The results folder is created when the code is run. The results folder contains a language-specific output data file as well as a `_results/tables-tex` folder containing the tables from the paper. Each table in the paper is a separate file in the `tables-tex` folder. The tables are named `table_1.tex`, `table_2.tex`, etc. The tables are in LaTeX format and can be included in a LaTeX document. You can check the output of the code by comparing the tables in the results folder to the tables in the paper as well as in the [Tables section of this readme](#tables)

## Tables

### Table 1

|                  | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| \(\Bar{V}\)=500  |  self-norm  |    \[-14.3 , 22.6\]     |      \[-40.0 , 35.9\]       |    5.2     |
|                  |  bootstrap  |    \[-13.1 , 22.1\]     |      \[-40.0 , 34.8\]       |    13.6    |
| \(\Bar{V}\)=1000 |  self-norm  |    \[-40.0 , 28.3\]     |      \[-40.0 , 57.4\]       |    4.4     |
|                  |  bootstrap  |    \[-40.0 , 26.6\]     |      \[-40.0 , 54.7\]       |    13.1    |

### Table 2

|                  | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| \(\Bar{V}\)=500  |  self-norm  |    \[-20.4 , 25.3\]     |      \[-40.0 , 38.1\]       |    15.5    |
|                  |  bootstrap  |    \[-13.1 , 22.1\]     |      \[-40.0 , 34.8\]       |    43.1    |
| \(\Bar{V}\)=1000 |  self-norm  |    \[-40.0 , 31.2\]     |      \[-40.0 , 61.2\]       |    14.7    |
|                  |  bootstrap  |    \[-40.0 , 26.6\]     |      \[-40.0 , 54.7\]       |    42.2    |