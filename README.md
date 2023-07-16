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

The tables below were computed in a personal laptop (Intel64 Family 6 Model 142 processor with 4 cores, 2.0 GHz, and 32GB of RAM). 

### Matlab tables

#### Table 1

##### Panel A

|                | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:--------------:|:-----------:|:---------------------:|:-------------------------:|:----------:|
| $\Bar{V}$=500  |  self-norm  |   \[-16.0 , 23.4\]    |     \[-40.0 , 39.3\]      |   453.5    |
|                |  bootstrap  |   \[-13.9 , 22.4\]    |     \[-40.0 , 38.5\]      |   1226.2   |
| $\Bar{V}$=1000 |  self-norm  |   \[-40.0 , 29.1\]    |     \[-40.0 , 63.1\]      |   446.8    |
|                |  bootstrap  |   \[-40.0 , 26.8\]    |     \[-40.0 , 60.2\]      |   1812.6   |

##### Panel B

|                | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:--------------:|:-----------:|:---------------------:|:-------------------------:|:----------:|
| $\Bar{V}$=500  |  self-norm  |   \[-14.3 , 22.6\]    |     \[-40.0 , 35.9\]      |    53.6    |
|                |  bootstrap  |   \[-13.1 , 22.1\]    |     \[-40.0 , 34.8\]      |    90.5    |
| $\Bar{V}$=1000 |  self-norm  |   \[-40.0 , 28.3\]    |     \[-40.0 , 57.4\]      |    41.1    |
|                |  bootstrap  |   \[-40.0 , 26.6\]    |     \[-40.0 , 54.7\]      |    88.6    |

#### Table 2

|                | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:--------------:|:-----------:|:---------------------:|:-------------------------:|:----------:|
| $\Bar{V}$=500  |  self-norm  |   \[-22.9 , 17.1\]    |     \[-40.0 , 37.9\]      |   157.6    |
|                |  bootstrap  |   \[-17.6 , 14.4\]    |     \[-40.0 , 35.3\]      |   276.8    |
| $\Bar{V}$=1000 |  self-norm  |   \[-40.0 , 17.0\]    |     \[-40.0 , 37.9\]      |   142.2    |
|                |  bootstrap  |   \[-40.0 , 14.3\]    |     \[-40.0 , 34.2\]      |   246.1    |

#### Table 3

| Test Stat. | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:----------:|:-----------:|:---------------------:|:-------------------------:|:----------:|
|    CCK     |  self-norm  |   $14.2^{\dagger}$    |     \[-40.0 , 12.8\]      |    39.8    |
|   RC-CCK   |  self-norm  |   \[-35.4 , 44.0\]    |     \[-40.0 , 13.8\]      |   273.6    |
|   RC-CCK   |  bootstrap  |   \[-35.6 , 43.3\]    |     \[-40.0 , 13.0\]      |   289.3    |
|   RC-CCK   |    SPUR1    |   \[-39.2 , 53.2\]    |     \[-40.0 , 18.4\]      |   2440.8   |

#### Table 4

|            |                 |   $\Bar{V}=500$    |                     |   $\Bar{V}=1000$    |                     |
|:----------:|:---------------:|:------------------:|:-------------------:|:-------------------:|:-------------------:|
|            |    parameter    |       linear       |      quadratic      |       linear        |      quadratic      |
|            | $\theta_{1,1}$  | \[ -22.2 , 43.7\]  |  \[ -22.4 , 76.7\]  |  \[ -40.0 , 49.6\]  |  \[ -40.0 , 82.0\]  |
|    Coca    | $\theta_{1,2}$  | \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |
|    Cola    | $\theta_{1,3}$  |                    |  \[ -10.0 , 10.0\]  |                     |  \[ -10.0 , 10.0\]  |
|            | $\mu_1$         | \[ -79.9 , 133.7\] | \[ -167.8 , 157.5\] | \[ -100.0 , 134.4\] | \[ -190.0 , 195.3\] |
|   Energy   | $\theta_{2,1}$  | \[ -40.0 , 53.6\]  |  \[ -40.0 , 67.6\]  |  \[ -40.0 , 78.2\]  |  \[ -40.0 , 91.6\]  |
|   Brands   | $\theta_{2,2}$  | \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |  \[ -20.0 , 50.0\]  |
|            | $\theta_{2,3}$  |                    |  \[ -10.0 , 10.0\]  |                     |  \[ -10.0 , 10.0\]  |
|            | $\mu_2$         | \[ -75.1 , 99.0\]  | \[ -105.8 , 119.9\] | \[ -75.1 , 126.0\]  | \[ -105.8 , 142.7\] |
| Comp. time |                 |        51.5        |        49.0         |        34.6         |        52.9         |

### R tables

#### Table 1

##### Panel A

| $\Bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:----------|:------------|:----------------------|:--------------------------|:-----------|
| 500       | SN2S        | \[-16.0, 23.0\]       | \[-40.0, 39.0\]           | 53.24      |
| 500       | EB2S        | \[-12.0, 22.0\]       | \[-40.0, 38.0\]           | 1472.28    |
| 1000      | SN2S        | \[-40.0, 29.0\]       | \[-40.0, 63.0\]           | 43.64      |
| 1000      | EB2S        | \[-40.0, 26.0\]       | \[-40.0, 60.0\]           | 1474.40    |

##### Panel B

| $\Bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:----------|:------------|:----------------------|:--------------------------|:-----------|
| 500       | SN2S        | \[-14.3, 22.6\]       | \[-40.0, 35.9\]           | 5.90       |
| 500       | EB2S        | \[-11.9, 21.7\]       | \[-40.0, 34.6\]           | 105.88     |
| 1000      | SN2S        | \[-40.0, 28.3\]       | \[-40.0, 57.4\]           | 7.53       |
| 1000      | EB2S        | \[-40.0, 26.8\]       | \[-40.0, 54.1\]           | 109.08     |

#### Table 2

| $\Bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:----------|:------------|:----------------------|:--------------------------|:-----------|
| 500       | SN2S        | \[-22.9, 17.1\]       | \[-40.0, 37.9\]           | 19.75      |
| 500       | EB2S        | \[-17.4, 14.1\]       | \[-40.0, 34.8\]           | 418.77     |
| 1000      | SN2S        | \[-40.0, 17.0\]       | \[-40.0, 37.9\]           | 9.68       |
| 1000      | EB2S        | \[-40.0, 13.4\]       | \[-40.0, 34.1\]           | 360.69     |

#### Table 4

|               | Parameter      | Linear           | Quadratic       | Linear          | Quadratic       |
|:--------------|:---------------|:-----------------|:----------------|:----------------|:----------------|
| Coca-Cola     | $\theta_{1,1}$ | \[-22.2, 43.7\]  | \[-21.9, 76.7\] | \[-40.0, 49.6\] | \[-40.0, 82.0\] |
|               | $\theta_{1,2}$ | \[-20.0, 50.0\]  | \[-20.0, 50.0\] | \[-20.0, 50.0\] | \[-20.0, 50.0\] |
|               | $\theta_{1,3}$ |                  | \[-10.0, 10.0\] |                 | \[-10.0, 10.0\] |
|               | $\mu_{1}$      | \[-18.7, -16.3\] | \[-17.8, 8.6\]  | \[-40.0, 2.3\]  | \[-40.0, 14.2\] |
| Energy Brands | $\theta_{2,1}$ | \[-40.0, 53.6\]  | \[-40.0, 67.6\] | \[-40.0, 78.2\] | \[-40.0, 91.6\] |
|               | $\theta_{2,2}$ | \[-20.0, 50.0\]  | \[-20.0, 50.0\] | \[-20.0, 50.0\] | \[-20.0, 50.0\] |
|               | $\theta_{2,3}$ |                  | \[-10.0, 10.0\] |                 | \[-10.0, 10.0\] |
|               | $\mu_{2}$      | \[0.0, 0.0\]     | \[0.0, 0.0\]    | \[0.0, 0.0\]    | \[0.0, 0.0\]    |
| Comp. Time    |                | 5.44             | 4.86            | 4.47            | 4.18            |

### Python tables

#### Table 1

##### Panel A

| $\Bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:----------|:------------|:---------------------:|:-------------------------:|:----------:|
| 500       | SN2S        |    \[-16.0, 23.0\]    |      \[-40.0, 39.0\]      |   11.608   |
| 500       | EB2S        |    \[-15.0, 22.0\]    |      \[-40.0, 39.0\]      |  1382.676  |
| 1000      | SN2S        |    \[-40.0, 29.0\]    |      \[-40.0, 63.0\]      |   5.746    |
| 1000      | EB2S        |    \[-40.0, 27.0\]    |      \[-40.0, 61.0\]      |  1563.830  |

##### Panel B

| $\Bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:----------|:------------|:---------------------:|:-------------------------:|:----------:|
| 500       | SN2S        |    \[-14.3, 22.6\]    |      \[-40.0, 35.9\]      |   3.228    |
| 500       | EB2S        |    \[-13.7, 22.3\]    |      \[-40.0, 34.5\]      |  123.181   |
| 1000      | SN2S        |    \[-40.0, 28.3\]    |      \[-40.0, 57.4\]      |   4.571    |
| 1000      | EB2S        |    \[-40.0, 27.4\]    |      \[-40.0, 54.1\]      |  112.642   |

#### Table 2

| $\Bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:----------|:------------|:---------------------:|:-------------------------:|:----------:|
| 500       | SN2S        |    \[-22.9, 17.1\]    |      \[-40.0, 37.9\]      |   8.060    |
| 500       | EB2S        |    \[-19.1, 14.9\]    |      \[-40.0, 35.0\]      |  420.637   |
| 1000      | SN2S        |    \[-40.0, 17.0\]    |      \[-40.0, 37.9\]      |   7.023    |
| 1000      | EB2S        |    \[-40.0, 13.8\]    |      \[-40.0, 34.0\]      |  452.133   |

#### Table 3

| $\Bar{V}$ | Crit. Value | $\theta_1$: Coca-Cola | $\theta_2$: Energy Brands | Comp. Time |
|:----------|:------------|:---------------------:|:-------------------------:|:----------:|
| 0         | SN2S        |     \[nan, 14.2\]     |      \[-40.0, 12.8\]      |   7.549    |
| 0         | SN2S        |    \[-35.4, 44.0\]    |      \[-40.0, 13.8\]      |   8.188    |
| 0         | EB2S        |    \[-36.5, 43.4\]    |      \[-40.0, 12.6\]      |  131.905   |
| 0         | SPUR1       |    \[-40.0, 54.5\]    |      \[-40.0, 18.3\]      |  671.975   |

#### Table 4

|               | Parameter      | Linear           | Quadratic       | Linear          | Quadratic       |
|:--------------|:---------------|:-----------------|:----------------|:----------------|:----------------|
| Coca-Cola     | $\theta_{1,1}$ | \[-22.2, 43.7\]  | \[-22.4, 76.7\] | \[-40.0, 49.6\] | \[-40.0, 82.0\] |
|               | $\theta_{1,2}$ | \[-20.0, 50.0\]  | \[-20.0, 50.0\] | \[-20.0, 50.0\] | \[-20.0, 50.0\] |
|               | $\theta_{1,3}$ |                  | \[-10.0, 10.0\] |                 | \[-10.0, 10.0\] |
|               | $\mu_{1}$      | \[-18.7, -16.3\] | \[-17.8, 8.6\]  | \[-40.0, 2.3\]  | \[-40.0, 14.2\] |
| Energy Brands | $\theta_{2,1}$ | \[-40.0, 53.6\]  | \[-40.0, 67.6\] | \[-40.0, 78.2\] | \[-40.0, 91.6\] |
|               | $\theta_{2,2}$ | \[-20.0, 50.0\]  | \[-20.0, 50.0\] | \[-20.0, 50.0\] | \[-20.0, 50.0\] |
|               | $\theta_{2,3}$ |                  | \[-10.0, 10.0\] |                 | \[-10.0, 10.0\] |
|               | $\mu_{2}$      | \[0.0, 0.0\]     | \[0.0, 0.0\]    | \[0.0, 0.0\]    | \[0.0, 0.0\]    |
| Comp. Time    |                | 2.148            | 5.468           | 2.828           | 1.054           |

