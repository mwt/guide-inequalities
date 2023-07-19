#!/bin/sh
cat << EOF >README.md
# Python Code for "A User's Guide for Inference in Models Defined by Moment Inequalities"

This folder contains PYTHON to replicate the results in the paper "A User's Guide for Inference in Models Defined by Moment Inequalities" by Canay, Illanes, and Velez available [here](https://faculty.wcas.northwestern.edu/iac879/wp/inequalities-guide.pdf). The code is organized with five table files and a folder with auxiliary functions.

## Table Files

The table files are:

- \`table_1a.py\`: Replicates Table 1, Panel A in Section 8.1.
- \`table_1b.py\`: Replicates Table 1, Panel B in Section 8.1.
- \`table_2.py\`: Replicates Table 2 in Section 8.2.1.
- \`table_3.py\`: Replicates Table 3 in Section 8.2.2.
- \`table_4.py\`: Replicates Table 4 in Section 8.2.3.

## Library Modules

The modules are contained in the folder \`ineq_functions\` and have the following dependency structure:
EOF

# String Replacements
# 1. Add a new line between function parameters
# 2. Change the title of the library modules section to h2
# 3. Substitute g_restriction.g_restriction(_diff) -> g_restriction(_diff)
pydoc-markdown |
sed -e 's/^\([^:]\+ : \)/>\n\1/' \
-e '/^# Library Modules$/d' \
-e 's/g_restriction\.g_restriction/g_restriction/' \
>>README.md
