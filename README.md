# Code for "A User's Guide for Inference in Models Defined by Moment Inequalities"

**This code is not yet ready for public use.**

This repository contains the code for the paper "A User's Guide for Inference in Models Defined by Moment Inequalities" by Canay, Illanes, and Velez available [here](https://faculty.wcas.northwestern.edu/iac879/wp/inequalities-guide.pdf).

## Structure

The code is organized into four folders:

* `data` contains fake data intended to be similar to the data used in the empirical application in the paper. The data is stored in several csv files. The file [`data/README.md`](data/README.md) contains a description of the data.
* `matlab` contains the code for the Matlab implementation of the algorithms. The file [`matlab/README.md`](matlab/README.md) contains a description of the Matlab code.
* `python` contains the code for the Python implementation of the algorithms. The file [`python/README.md`](python/README.md) contains a description of the Python code.
* `r` contains the code for the R implementation of the algorithms. The file [`r/README.md`](r/README.md) contains a description of the R code.

In each of the three code implementations, there is one script for each table in the paper. This script produces the output for the table. The scripts are named `table_1a.m` (or `.py` or `.R`), `table_1b.m`, etc. The scripts are self-contained and can be run independently of each other.

## Outputs

Each implementation produces outputs in a folder named `_results`. The results folder is not included in the repository. The results folder is created when the code is run. The results folder contains a language-specific output data file as well as a `_results/tables-tex` folder containing the tables from the paper. Each table in the paper is a separate file in the `tables-tex` folder. The tables are named `table_1.tex`, `table_2.tex`, etc. The tables are in LaTeX format and can be included in a LaTeX document. You can check the output of the code by comparing the tables in the results folder to the tables in the paper as well as in the [Tables section of this README](#tables).

## Tables

### Matlab tables

#### Table 1

##### Panel A

|                  | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| $\bar{V}$=500  |  self-norm  |    \[-16.0 , 23.4\]     |      \[-40.0 , 39.3\]       |    45.1    |
|                  |  bootstrap  |    \[-13.9 , 22.4\]     |      \[-40.0 , 38.5\]       |   179.1    |
| $\bar{V}$=1000 |  self-norm  |    \[-40.0 , 29.1\]     |      \[-40.0 , 63.1\]       |    53.6    |
|                  |  bootstrap  |    \[-40.0 , 26.8\]     |      \[-40.0 , 60.2\]       |   214.6    |

##### Panel B

|                  | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| $\bar{V}$=500  |  self-norm  |    \[-14.3 , 22.6\]     |      \[-40.0 , 35.9\]       |    5.0     |
|                  |  bootstrap  |    \[-13.1 , 22.1\]     |      \[-40.0 , 34.8\]       |    12.8    |
| $\bar{V}$=1000 |  self-norm  |    \[-40.0 , 28.3\]     |      \[-40.0 , 57.4\]       |    4.3     |
|                  |  bootstrap  |    \[-40.0 , 26.6\]     |      \[-40.0 , 54.7\]       |    12.8    |

#### Table 2

|                  | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :--------------: | :---------: | :---------------------: | :-------------------------: | :--------: |
| $\bar{V}$=500  |  self-norm  |    \[-21.0 , 17.1\]     |      \[-40.0 , 39.1\]       |    14.9    |
|                  |  bootstrap  |    \[-16.0 , 14.6\]     |      \[-40.0 , 36.6\]       |    42.1    |
| $\bar{V}$=1000 |  self-norm  |    \[-40.0 , 17.0\]     |      \[-40.0 , 62.8\]       |    14.1    |
|                  |  bootstrap  |    \[-40.0 , 13.9\]     |      \[-40.0 , 55.1\]       |    41.4    |

#### Table 3

| Test Stat. | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :--------: | :---------: | :---------------------: | :-------------------------: | :--------: |
|    CCK     |  self-norm  |   $14.2^{\dagger}$    |      \[-40.0 , 12.8\]       |    25.0    |
|   RC-CCK   |  self-norm  |    \[-35.4 , 44.0\]     |      \[-40.0 , 13.8\]       |    37.0    |
|   RC-CCK   |  bootstrap  |    \[-35.6 , 43.3\]     |      \[-40.0 , 13.0\]       |    42.7    |
|   RC-CCK   |    SPUR1    |    \[-39.2 , 53.2\]     |      \[-40.0 , 18.4\]       |    54.4    |

#### Table 4

|            |                   |                    |                     |                     |                     |
| :--------: | :---------------: | :----------------: | :-----------------: | :-----------------: | :-----------------: |
|            |     parameter     |       linear       |      quadratic      |       linear        |      quadratic      |
|            | $\theta_{1,1}$  | \[ -22.2 , 43.7\]  |  \[ -22.4 , 76.7\]  |  \[ -40.0 , 49.6\]  |  \[ -40.0 , 82.0\]  |
|    Coca    | $\theta_{1,2}$  | \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |
|    Cola    | $\theta_{1,3}$  |   \[ 0.0 , 0.0\]   |  \[ -10.0 , 10.0\]  |   \[ 0.0 , 0.0\]    |  \[ -10.0 , 10.0\]  |
|            | $\theta_1(\mu)$ | \[ -79.9 , 133.7\] | \[ -167.8 , 157.5\] | \[ -100.0 , 134.4\] | \[ -190.0 , 195.3\] |
|   Energy   | $\theta_{2,1}$  | \[ -40.0 , 53.6\]  |  \[ -40.0 , 67.6\]  |  \[ -40.0 , 78.2\]  |  \[ -40.0 , 91.6\]  |
|   Brands   | $\theta_{2,2}$  | \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |
|            | $\theta_{2,3}$  |   \[ 0.0 , 0.0\]   |  \[ -10.0 , 10.0\]  |   \[ 0.0 , 0.0\]    |  \[ -10.0 , 10.0\]  |
|            | $\theta_2(\mu)$ | \[ -75.1 , 99.0\]  | \[ -105.8 , 119.9\] | \[ -75.1 , 126.0\]  | \[ -105.8 , 142.7\] |
| Comp. time |                   |        11.5        |        12.5         |         9.0         |         9.1         |

### R tables

#### Table 1

##### Panel A

| $\bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------- | :-------------------------- | :--------- |
| 500         | SN2S        | \[-16.0, 23.0\]         | \[-40.0, 39.0\]             | 6.14       |
| 500         | EB2S        | \[-12.0, 22.0\]         | \[-40.0, 38.0\]             | 594.25     |
| 1000        | SN2S        | \[-40.0, 29.0\]         | \[-40.0, 63.0\]             | 6.03       |
| 1000        | EB2S        | \[-40.0, 26.0\]         | \[-40.0, 60.0\]             | 463.49     |

##### Panel B

| $\bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------- | :-------------------------- | :--------- |
| 500         | SN2S        | \[-14.3, 22.6\]         | \[-40.0, 35.9\]             | 1.02       |
| 500         | EB2S        | \[-11.9, 21.7\]         | \[-40.0, 34.6\]             | 41.50      |
| 1000        | SN2S        | \[-40.0, 28.3\]         | \[-40.0, 57.4\]             | 0.93       |
| 1000        | EB2S        | \[-40.0, 26.8\]         | \[-40.0, 54.1\]             | 39.69      |

#### Table 2

| $\bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------- | :-------------------------- | :--------- |
| 500         | SN2S        | \[-21.0, 17.1\]         | \[-40.0, 39.1\]             | 1.77       |
| 500         | EB2S        | \[-15.3, 13.9\]         | \[-40.0, 36.1\]             | 171.19     |
| 1000        | SN2S        | \[-40.0, 17.0\]         | \[-40.0, 62.8\]             | 1.70       |
| 1000        | EB2S        | \[-40.0, 13.1\]         | \[-40.0, 54.9\]             | 161.99     |

#### Table 4

|               | Parameter        | Linear           | Quadratic       | Linear          | Quadratic       |
| :------------ | :--------------- | :--------------- | :-------------- | :-------------- | :-------------- |
| Coca-Cola     | $\theta_{1,1}$ | \[-22.2, 43.7\]  | \[-21.9, 76.7\] | \[-40.0, 49.6\] | \[-40.0, 82.0\] |
|               | $\theta_{1,2}$ | \[-20.0, 50.0\]  | \[-20.0, 50.0\] | \[-20.0, 50.0\] | \[-20.0, 50.0\] |
|               | $\theta_{1,3}$ | \[0.0, 0.0\]     | \[-10.0, 10.0\] | \[0.0, 0.0\]    | \[-10.0, 10.0\] |
|               | $\theta_{1}$   | \[-18.7, -16.3\] | \[-17.8, 8.6\]  | \[-40.0, 2.3\]  | \[-40.0, 14.2\] |
| Energy Brands | $\theta_{2,1}$ | \[-40.0, 53.6\]  | \[-40.0, 67.6\] | \[-40.0, 78.2\] | \[-40.0, 91.6\] |
|               | $\theta_{2,2}$ | \[-20.0, 50.0\]  | \[-20.0, 50.0\] | \[-20.0, 50.0\] | \[-20.0, 50.0\] |
|               | $\theta_{2,3}$ | \[0.0, 0.0\]     | \[-10.0, 10.0\] | \[0.0, 0.0\]    | \[-10.0, 10.0\] |
|               | $\theta_{2}$   | \[0.0, 0.0\]     | \[0.0, 0.0\]    | \[0.0, 0.0\]    | \[0.0, 0.0\]    |
| Comp. Time    |                  | 1.22             | 1.40            | 1.37            | 1.21            |

### Python tables

#### Table 1

##### Panel A

| $\bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 500         | SN2S        |     \[-16.0, 23.0\]     |       \[-40.0, 39.0\]       |   2.314    |
| 500         | EB2S        |     \[-15.0, 22.0\]     |       \[-40.0, 39.0\]       |  412.102   |
| 1000        | SN2S        |     \[-40.0, 29.0\]     |       \[-40.0, 63.0\]       |   2.144    |
| 1000        | EB2S        |     \[-40.0, 27.0\]     |       \[-40.0, 61.0\]       |  413.901   |

##### Panel B

| $\bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 500         | SN2S        |     \[-14.3, 22.6\]     |       \[-40.0, 35.9\]       |   1.011    |
| 500         | EB2S        |     \[-13.7, 22.3\]     |       \[-40.0, 34.5\]       |   29.815   |
| 1000        | SN2S        |     \[-40.0, 28.3\]     |       \[-40.0, 57.4\]       |   0.757    |
| 1000        | EB2S        |     \[-40.0, 27.4\]     |       \[-40.0, 54.1\]       |   29.985   |

#### Table 2

| $\bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 500         | SN2S        |     \[-21.0, 17.1\]     |       \[-40.0, 39.1\]       |   1.118    |
| 500         | EB2S        |     \[-17.3, 15.3\]     |       \[-40.0, 36.5\]       |  119.178   |
| 1000        | SN2S        |     \[-40.0, 17.0\]     |       \[-40.0, 62.8\]       |   0.872    |
| 1000        | EB2S        |     \[-40.0, 13.8\]     |       \[-40.0, 54.8\]       |  121.414   |

#### Table 3

| $\bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
| :---------- | :---------- | :---------------------: | :-------------------------: | :--------: |
| 0           | SN2S        |      \[nan, 14.2\]      |       \[-40.0, 12.8\]       |   0.998    |
| 0           | SN2S        |     \[-35.4, 44.0\]     |       \[-40.0, 13.8\]       |   1.217    |
| 0           | EB2S        |     \[-36.5, 43.4\]     |       \[-40.0, 12.6\]       |   30.976   |
| 0           | SPUR1       |     \[-40.0, 54.5\]     |       \[-40.0, 18.3\]       |  181.835   |

#### Table 4

|               | Parameter        | Linear           | Quadratic       | Linear          | Quadratic       |
| :------------ | :--------------- | :--------------- | :-------------- | :-------------- | :-------------- |
| Coca-Cola     | $\theta_{1,1}$ | \[-22.2, 43.7\]  | \[-22.4, 76.7\] | \[-40.0, 49.6\] | \[-40.0, 82.0\] |
|               | $\theta_{1,2}$ | \[-20.0, 50.0\]  | \[-20.0, 50.0\] | \[-20.0, 50.0\] | \[-20.0, 50.0\] |
|               | $\theta_{1,3}$ | \[0.0, 0.0\]     | \[-10.0, 10.0\] | \[0.0, 0.0\]    | \[-10.0, 10.0\] |
|               | $\theta_{1}$   | \[-18.7, -16.3\] | \[-17.8, 8.6\]  | \[-40.0, 2.3\]  | \[-40.0, 14.2\] |
| Energy Brands | $\theta_{2,1}$ | \[-40.0, 53.6\]  | \[-40.0, 67.6\] | \[-40.0, 78.2\] | \[-40.0, 91.6\] |
|               | $\theta_{2,2}$ | \[-20.0, 50.0\]  | \[-20.0, 50.0\] | \[-20.0, 50.0\] | \[-20.0, 50.0\] |
|               | $\theta_{2,3}$ | \[0.0, 0.0\]     | \[-10.0, 10.0\] | \[0.0, 0.0\]    | \[-10.0, 10.0\] |
|               | $\theta_{2}$   | \[0.0, 0.0\]     | \[0.0, 0.0\]    | \[0.0, 0.0\]    | \[0.0, 0.0\]    |
| Comp. Time    |                  | 0.528            | 0.847           | 0.724           | 0.751           |

