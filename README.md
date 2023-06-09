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
| \(\Bar{V}\)=500  |  self-norm  |    \[-14.3 , 22.6\]     |      \[-40.0 , 35.9\]       |    5.5     |
|                  |  bootstrap  |    \[-13.1 , 22.1\]     |      \[-40.0 , 34.8\]       |    14.0    |
| \(\Bar{V}\)=1000 |  self-norm  |    \[-40.0 , 28.3\]     |      \[-40.0 , 57.4\]       |    4.4     |
|                  |  bootstrap  |    \[-40.0 , 26.6\]     |      \[-40.0 , 54.7\]       |    13.0    |

#### Table 2

|                  | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| \(\Bar{V}\)=500  |  self-norm  |    \[-23.0 , 17.1\]     |      \[-40.0 , 37.9\]       |    15.3    |
|                  |  bootstrap  |    \[-18.9 , 15.1\]     |      \[-40.0 , 35.5\]       |    43.5    |
| \(\Bar{V}\)=1000 |  self-norm  |    \[-40.0 , 17.0\]     |      \[-40.0 , 37.9\]       |    15.2    |
|                  |  bootstrap  |    \[-40.0 , 14.6\]     |      \[-40.0 , 34.4\]       |    42.8    |

#### Table 3

| Test Stat. | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :--------: | :---------: | :---------------------: | :-------------------------: | :--------: |
|    CCK     |  self-norm  |   \(14.2^{\dagger}\)    |      \[-40.0 , 12.8\]       |    26.3    |
|   RC-CCK   |  self-norm  |    \[-35.4 , 44.0\]     |      \[-40.0 , 13.8\]       |    38.4    |
|   RC-CCK   |  bootstrap  |    \[-35.6 , 43.3\]     |      \[-40.0 , 13.0\]       |    45.4    |
|   RC-CCK   |    SPUR1    |    \[-39.2 , 53.2\]     |      \[-40.0 , 18.4\]       |    55.8    |

#### Table 4

|            |                   |                    |                     |                     |                     |
| :--------: | :---------------: | :----------------: | :-----------------: | :-----------------: | :-----------------: |
|            |     parameter     |       linear       |      quadratic      |       linear        |      quadratic      |
|            | \(\theta_{1,1}\)  | \[ -22.2 , 43.7\]  |  \[ -22.4 , 76.7\]  |  \[ -40.0 , 49.6\]  |  \[ -40.0 , 82.0\]  |
|    Coca    | \(\theta_{1,2}\)  | \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |
|    Cola    | \(\theta_{1,3}\)  |   \[ 0.0 , 0.0\]   |  \[ -10.0 , 10.0\]  |   \[ 0.0 , 0.0\]    |  \[ -10.0 , 10.0\]  |
|            | \(\theta_1(\mu)\) | \[ -79.9 , 133.7\] | \[ -167.8 , 157.5\] | \[ -100.0 , 134.4\] | \[ -190.0 , 195.3\] |
|   Energy   | \(\theta_{2,1}\)  | \[ -40.0 , 53.6\]  |  \[ -40.0 , 67.6\]  |  \[ -40.0 , 78.2\]  |  \[ -40.0 , 91.6\]  |
|   Brands   | \(\theta_{2,2}\)  | \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |
|            | \(\theta_{2,3}\)  |   \[ 0.0 , 0.0\]   |  \[ -10.0 , 10.0\]  |   \[ 0.0 , 0.0\]    |  \[ -10.0 , 10.0\]  |
|            | \(\theta_2(\mu)\) | \[ -75.1 , 99.0\]  | \[ -105.8 , 119.9\] | \[ -75.1 , 126.0\]  | \[ -105.8 , 142.7\] |
| Comp. time |                   |        12.0        |        12.9         |         9.4         |         9.4         |

#### Table B2

|                  | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| \(\Bar{V}\)=500  |  self-norm  |    \[-16.0 , 23.4\]     |      \[-40.0 , 39.3\]       |    46.1    |
|                  |  bootstrap  |    \[-13.9 , 22.4\]     |      \[-40.0 , 38.5\]       |   183.1    |
| \(\Bar{V}\)=1000 |  self-norm  |    \[-40.0 , 29.1\]     |      \[-40.0 , 63.1\]       |    55.8    |
|                  |  bootstrap  |    \[-40.0 , 26.8\]     |      \[-40.0 , 60.2\]       |   219.1    |

### R tables

#### Table 1

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------- | :-------------------------- | :--------- |
| 500         | SN2S        | \[-14.3, 22.6\]         | \[-40, 35.9\]               | 2.02       |
| 500         | EB2S        | \[-11.9, 21.7\]         | \[-40, 34.6\]               | 43.44      |
| 1000        | SN2S        | \[-40, 28.3\]           | \[-40, 57.4\]               | 1.73       |
| 1000        | EB2S        | \[-40, 26.8\]           | \[-40, 54.1\]               | 41.61      |

#### Table 2

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------- | :-------------------------- | :--------- |
| 500         | SN2S        | \[-23, 17.1\]           | \[-40, 37.9\]               | 5.51       |
| 500         | EB2S        | \[-18.4, 14.3\]         | \[-40, 35.1\]               | 189.27     |
| 1000        | SN2S        | \[-40, 17\]             | \[-40, 37.9\]               | 5.21       |
| 1000        | EB2S        | \[-40, 13.9\]           | \[-40, 34.3\]               | 182.50     |

### Python tables

#### Table 1

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 500         | SN2S        |     \[-14.3, 22.6\]     |       \[-40.0, 35.9\]       |   1.134    |
| 500         | EB2S        |     \[-13.7, 22.3\]     |       \[-40.0, 34.5\]       |   31.983   |
| 1000        | SN2S        |     \[-40.0, 28.3\]     |       \[-40.0, 57.4\]       |   0.732    |
| 1000        | EB2S        |     \[-40.0, 27.4\]     |       \[-40.0, 54.1\]       |   31.810   |

#### Table 2

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 500         | SN2S        |     \[-23.0, 17.1\]     |       \[-40.0, 37.9\]       |   1.431    |
| 500         | EB2S        |     \[-20.9, 16.0\]     |       \[-40.0, 35.3\]       |  131.514   |
| 1000        | SN2S        |     \[-40.0, 17.0\]     |       \[-40.0, 37.9\]       |   1.157    |
| 1000        | EB2S        |     \[-40.0, 14.5\]     |       \[-40.0, 34.2\]       |  142.083   |

#### Table 3

| \(\Bar{V}\) | Crit. Value | \(\theta_1\): Coca-Cola | \(\theta_2\): Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 0           | SN2S        |      \[nan, 14.2\]      |       \[-40.0, 12.8\]       |   1.141    |
| 0           | SN2S        |     \[-35.4, 44.0\]     |       \[-40.0, 13.8\]       |   1.205    |
| 0           | EB2S        |     \[-36.5, 43.4\]     |       \[-40.0, 12.6\]       |   35.062   |
| 0           | SPUR1       |     \[-40.0, 54.5\]     |       \[-40.0, 18.3\]       |  222.222   |

#### Table 4

|               | Parameter        | Linear           | Quadratic       | Linear          | Quadratic       |
| :------------ | :--------------- | :--------------- | :-------------- | :-------------- | :-------------- |
| Coca-Cola     | \(\theta_{1,1}\) | \[-22.2, 43.7\]  | \[-22.4, 76.7\] | \[-40.0, 49.6\] | \[-40.0, 82.0\] |
|               | \(\theta_{1,2}\) | \[-20.0, 50.0\]  | \[-20.0, 50.0\] | \[-20.0, 50.0\] | \[-20.0, 50.0\] |
|               | \(\theta_{1,3}\) | \[0.0, 0.0\]     | \[-10.0, 10.0\] | \[0.0, 0.0\]    | \[-10.0, 10.0\] |
|               | \(\theta_{1}\)   | \[-18.7, -16.3\] | \[-17.8, 8.6\]  | \[-40.0, 2.3\]  | \[-40.0, 14.2\] |
| Energy Brands | \(\theta_{2,1}\) | \[-40.0, 53.6\]  | \[-40.0, 67.6\] | \[-40.0, 78.2\] | \[-40.0, 91.6\] |
|               | \(\theta_{2,2}\) | \[-20.0, 50.0\]  | \[-20.0, 50.0\] | \[-20.0, 50.0\] | \[-20.0, 50.0\] |
|               | \(\theta_{2,3}\) | \[0.0, 0.0\]     | \[-10.0, 10.0\] | \[0.0, 0.0\]    | \[-10.0, 10.0\] |
|               | \(\theta_{2}\)   | \[0.0, 0.0\]     | \[0.0, 0.0\]    | \[0.0, 0.0\]    | \[0.0, 0.0\]    |
| Comp. Time    |                  | 0.540            | 0.870           | 0.734           | 0.760           |

