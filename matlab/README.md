# MATLAB Code for "A User's Guide for Inference in Models Defined by Moment Inequalities"

This folder contains MATLAB to replicate the results in the paper "A User's Guide for Inference in Models Defined by Moment Inequalities" by Canay, Illanes, and Velez available [here](https://faculty.wcas.northwestern.edu/iac879/wp/inequalities-guide.pdf). The code is organized with five table files and a folder with auxiliary functions.

## Table Files

The table files are:

- `table_1a.m`: Replicates Table 1, Panel A in Section 8.1.
- `table_1b.m`: Replicates Table 1, Panel B in Section 8.1.
- `table_2.m`: Replicates Table 2 in Section 8.2.1.
- `table_3.m`: Replicates Table 3 in Section 8.2.2.
- `table_4.m`: Replicates Table 4 in Section 8.2.3.

## Functions

The auxiliary functions are contained in the folder `1_functions` and have the following dependency structure:

### Table 1 and 2

```yaml
G_restriction:
  - m_function:
      - MomentFunct_L
      - MomentFunct_U
  - m_hat
  - cvalue_SN2S:
      - cvalue_SN
  - cvalue_EB2S
```

### Table 3

```yaml
compute_An_vec:
  - m_function:
      - MomentFunct_L
      - MomentFunct_U
  - std_B_vec:
      - m_hat
  - An_star:
      - m_hat

G_restriction:
  - m_function:
      - MomentFunct_L
      - MomentFunct_U
  - m_hat
  - cvalue_SN2S:
      - cvalue_SN
  - cvalue_EB2S:
  - cvalue_SPUR1:
      - std_B_vec:
          - m_hat
      - Tn_star:
          - m_hat
```

### Table 4

```yaml
G_restriction_fmin:
  - m_functionv2:
      - MomentFunct_Lv2
      - MomentFunct_Uv2
  - m_functionv3:
      - MomentFunct_Lv2
      - MomentFunct_Uv2
      - find_dist
  - m_hat
  - cvalue_SN
  - cvalue_SN2S
  - cvalue_EB2S
```
