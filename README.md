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
| \(\Bar{V}\)=500  |  self-norm  |    \[-14.3 , 22.6\]     |      \[-40.0 , 35.9\]       |    5.8     |
|                  |  bootstrap  |    \[-13.1 , 22.1\]     |      \[-40.0 , 34.8\]       |    13.4    |
| \(\Bar{V}\)=1000 |  self-norm  |    \[-40.0 , 28.3\]     |      \[-40.0 , 57.4\]       |    4.3     |
|                  |  bootstrap  |    \[-40.0 , 26.6\]     |      \[-40.0 , 54.7\]       |    13.3    |

#### Table 2

|                  | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| \(\Bar{V}\)=500  |  self-norm  |    \[-23.0 , 17.1\]     |      \[-40.0 , 37.9\]       |    15.4    |
|                  |  bootstrap  |    \[-18.9 , 15.1\]     |      \[-40.0 , 35.5\]       |    42.4    |
| \(\Bar{V}\)=1000 |  self-norm  |    \[-40.0 , 17.0\]     |      \[-40.0 , 37.9\]       |    14.8    |
|                  |  bootstrap  |    \[-40.0 , 14.6\]     |      \[-40.0 , 34.4\]       |    42.8    |

#### Table 3

| Test Stat. | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :--------: | :---------: | :---------------------: | :-------------------------: | :--------: |
|    CCK     |  self-norm  |   \(14.2^{\dagger}\)    |      \[-40.0 , 12.8\]       |    27.7    |
|   RC-CCK   |  self-norm  |    \[-35.4 , 44.0\]     |      \[-40.0 , 13.8\]       |    38.3    |
|   RC-CCK   |  bootstrap  |    \[-35.6 , 43.3\]     |      \[-40.0 , 13.0\]       |    44.5    |
|   RC-CCK   |    SPUR1    |    \[-39.2 , 53.2\]     |      \[-40.0 , 18.4\]       |    60.4    |

#### Table 4

|            |                   |                     |                     |                     |                     |
| :--------: | :---------------: | :-----------------: | :-----------------: | :-----------------: | :-----------------: |
|            |     parameter     |       linear        |      quadratic      |       linear        |      quadratic      |
|            | \(\theta_{1,1}\)  | \[ -22.5 , 100.0\]  | \[ -40.0 , 100.0\]  | \[ -40.0 , 100.0\]  | \[ -40.0 , 100.0\]  |
|    Coca    | \(\theta_{1,2}\)  |   \[ -2.9 , 0.1\]   |  \[ -20.0 , 50.0\]  |   \[ -5.7 , 0.1\]   |  \[ -20.0 , 50.0\]  |
|    Cola    | \(\theta_{1,3}\)  |   \[ 0.0 , 0.0\]    |   \[ 0.8 , 10.0\]   |   \[ 0.0 , 0.0\]    |  \[ -10.0 , -0.2\]  |
|            | \(\theta_1(\mu)\) | \[ -100.0 , 250.0\] | \[ -190.0 , 340.0\] | \[ -100.0 , 250.0\] | \[ -190.0 , 100.0\] |
|   Energy   | \(\theta_{2,1}\)  | \[ -40.0 , 100.0\]  | \[ -40.0 , 100.0\]  | \[ -40.0 , 100.0\]  | \[ -40.0 , 100.0\]  |
|   Brands   | \(\theta_{2,2}\)  |  \[ -20.0 , 0.2\]   |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 0.2\]   |  \[ -20.0 , 50.0\]  |
|            | \(\theta_{2,3}\)  |   \[ 0.0 , 0.0\]    |  \[ -10.0 , 10.0\]  |   \[ 0.0 , 0.0\]    |  \[ -10.0 , 10.0\]  |
|            | \(\theta_2(\mu)\) | \[ -80.0 , 200.0\]  | \[ -120.0 , 240.0\] | \[ -80.0 , 200.0\]  | \[ -120.0 , 240.0\] |
| Comp. time |                   |        15.3         |        13.0         |         9.2         |         8.8         |

#### Table B2

|                  | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| \(\Bar{V}\)=500  |  self-norm  |    \[-16.0 , 23.4\]     |      \[-40.0 , 39.3\]       |    46.5    |
|                  |  bootstrap  |    \[-13.9 , 22.4\]     |      \[-40.0 , 38.5\]       |   183.6    |
| \(\Bar{V}\)=1000 |  self-norm  |    \[-40.0 , 29.1\]     |      \[-40.0 , 63.1\]       |    54.9    |
|                  |  bootstrap  |    \[-40.0 , 26.8\]     |      \[-40.0 , 60.2\]       |   219.7    |

### R tables

#### Table 1

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------- | :-------------------------- | :--------- |
| 500         | SN2S        | \[-14.3, 22.6\]         | \[-40, 35.9\]               | 2.18       |
| 500         | EB2S        | \[-11.9, 21.7\]         | \[-40, 34.6\]               | 47.34      |
| 1000        | SN2S        | \[-40, 28.3\]           | \[-40, 57.4\]               | 1.85       |
| 1000        | EB2S        | \[-40, 26.8\]           | \[-40, 54.1\]               | 46.57      |

#### Table 2

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------- | :-------------------------- | :--------- |
| 500         | SN2S        | \[-23, 17.1\]           | \[-40, 37.9\]               | 5.60       |
| 500         | EB2S        | \[-18.4, 14.3\]         | \[-40, 35.1\]               | 190.24     |
| 1000        | SN2S        | \[-40, 17\]             | \[-40, 37.9\]               | 5.65       |
| 1000        | EB2S        | \[-40, 13.9\]           | \[-40, 34.3\]               | 196.63     |

### Python tables

#### Table 1

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 500         | SN2S        |     \[-14.3, 22.6\]     |       \[-40.0, 35.9\]       |   0.862    |
| 500         | EB2S        |     \[-13.7, 22.3\]     |       \[-40.0, 34.5\]       |   30.821   |
| 1000        | SN2S        |     \[-40.0, 28.3\]     |       \[-40.0, 57.4\]       |   0.850    |
| 1000        | EB2S        |     \[-40.0, 27.4\]     |       \[-40.0, 54.1\]       |   30.713   |

#### Table 2

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 500         | SN2S        |     \[-23.0, 17.1\]     |       \[-40.0, 37.9\]       |   1.326    |
| 500         | EB2S        |     \[-20.9, 16.0\]     |       \[-40.0, 35.3\]       |  121.815   |
| 1000        | SN2S        |     \[-40.0, 17.0\]     |       \[-40.0, 37.9\]       |   1.178    |
| 1000        | EB2S        |     \[-40.0, 14.5\]     |       \[-40.0, 34.2\]       |  120.974   |

#### Table 3

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 0           | SN2S        |      \[nan, 14.2\]      |       \[-40.0, 12.8\]       |   1.013    |
| 0           | SN2S        |     \[-35.4, 44.0\]     |       \[-40.0, 13.8\]       |   1.113    |
| 0           | EB2S        |     \[-36.5, 43.4\]     |       \[-40.0, 12.6\]       |   30.973   |
| 0           | SPUR1       |     \[-40.0, 54.5\]     |       \[-40.0, 18.3\]       |  183.228   |

