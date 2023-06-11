#!/bin/sh
echo "# Python Code for \"A User's Guide for Inference in Models Defined by Moment Inequalities\"" >README.md

# Add extra line breaks for parameters
pydoc-markdown |
    sed -e 's/^\([^:]+ : \)/>\n\1/' \
        -e 's/# Library Modules/## Library Modules/' >>README.md
