#!/bin/sh
echo "# Python Code for \"A User's Guide for Inference in Models Defined by Moment Inequalities\"" >README.md

# String Replacements
# 1. Add a new line between function parameters
# 2. Change the title of the library modules section to h2
# 3. Substitute g_restriction.g_restriction(_diff) -> g_restriction(_diff)
pydoc-markdown |
    sed -e 's/^\([^:]\+ : \)/>\n\1/' \
        -e 's/# Library Modules/## Library Modules/' \
        -e 's/g_restriction\.g_restriction/g_restriction/' \
        >>README.md
