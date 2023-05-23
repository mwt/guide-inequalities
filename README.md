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

Each implementation produces outputs in a folder named `_results`. The results folder is not included in the repository. The results folder is created when the code is run. The results folder contains a language-specific output data file as well as a `_results/tables-tex` folder containing the tables from the paper. Each table in the paper is a separate file in the `tables-tex` folder. The tables are named `table_1.tex`, `table_2.tex`, etc. The tables are in LaTeX format and can be included in a LaTeX document. You can check the output of the code by comparing the tables in the results folder to the tables in the paper as well as in the [Tables section of this README](#tables).

## Tables

### Matlab tables

#### Table 1

|                  | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| \(\Bar{V}\)=500  |  self-norm  |    \[-14.3 , 22.6\]     |      \[-40.0 , 35.9\]       |    5.3     |
|                  |  bootstrap  |    \[-13.1 , 22.1\]     |      \[-40.0 , 34.8\]       |    13.3    |
| \(\Bar{V}\)=1000 |  self-norm  |    \[-40.0 , 28.3\]     |      \[-40.0 , 57.4\]       |    4.3     |
|                  |  bootstrap  |    \[-40.0 , 26.6\]     |      \[-40.0 , 54.7\]       |    13.2    |

#### Table 2

|                  | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| \(\Bar{V}\)=500  |  self-norm  |    \[-23.0 , 17.1\]     |      \[-40.0 , 37.9\]       |    15.5    |
|                  |  bootstrap  |    \[-18.9 , 15.1\]     |      \[-40.0 , 35.5\]       |    43.1    |
| \(\Bar{V}\)=1000 |  self-norm  |    \[-40.0 , 17.0\]     |      \[-40.0 , 37.9\]       |    14.5    |
|                  |  bootstrap  |    \[-40.0 , 14.6\]     |      \[-40.0 , 34.4\]       |    42.2    |

### R tables

#### Table 1

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------- | :-------------------------- | :--------- |
| 500         | SN2S        | \[-14.3, 22.6\]         | \[-40, 35.9\]               | 4.98       |
| 500         | EB2S        | \[-11.9, 21.7\]         | \[-40, 34.6\]               | 45.09      |
| 1000        | SN2S        | \[-40, 28.3\]           | \[-40, 57.4\]               | 4.78       |
| 1000        | EB2S        | \[-40, 26.8\]           | \[-40, 54.1\]               | 44.18      |

### Python tables

#### Table 1

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 500         | SN2S        |    \[-14.00, 22.60\]    |      \[-40.00, 35.90\]      |   0.895    |
| 500         | EB2S        |    \[-13.70, 22.30\]    |      \[-40.00, 34.50\]      |   31.083   |
| 1000        | SN2S        |    \[-40.00, 28.30\]    |      \[-40.00, 57.40\]      |   0.816    |
| 1000        | EB2S        |    \[-40.00, 27.30\]    |      \[-40.00, 54.00\]      |   33.548   |

#### Table 2

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 500         | SN2S        |    \[-22.70, 17.00\]    |      \[-40.00, 37.90\]      |   1.327    |
| 500         | EB2S        |    \[-20.80, 16.00\]    |      \[-40.00, 35.30\]      |  123.378   |
| 1000        | SN2S        |    \[-40.00, 17.00\]    |      \[-40.00, 37.90\]      |   1.223    |
| 1000        | EB2S        |    \[-40.00, 14.50\]    |      \[-40.00, 34.20\]      |  121.878   |

