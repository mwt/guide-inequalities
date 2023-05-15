#/bin/bash

SCRIPT_DIR="$(dirname -- "$0")"

# Change to the directory of this script
cd "$SCRIPT_DIR"

# Delete the old tables
sed -i '/^## Tables/q' README.md

#==============================================================================
# Matlab tables
#==============================================================================

# Run the matlab scripts if tables don't exist
## Matlab
if [ ! -f ./matlab/_results/tables-tex/table_1.tex ]; then
    matlab -batch "run('matlab/table_1.m')"
fi
if [ ! -f ./matlab/_results/tables-tex/table_2.tex ]; then
    matlab -batch "run('matlab/table_2.m')"
fi

## R
if [ ! -f ./r/_results/tables-tex/table_1.tex ]; then
    cd 'r' && {
        Rscript --vanilla "table_1.R"
        cd -
    }
fi

# Insert the new tables
cat <<EOF >>README.md

### Matlab tables

#### Table 1

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_1.tex)

#### Table 2

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_2.tex)

### R tables

#### Table 1

$(pandoc -f latex -t gfm ./r/_results/tables-tex/table_1.tex)

EOF
