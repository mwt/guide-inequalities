#/bin/bash

SCRIPT_DIR="$(dirname -- "$0")"

# Change to the directory of this script
cd "$SCRIPT_DIR"

# Delete the old tables
tr '\n' '\t' <README.md |       # Start by replacing all newlines with tabs
    sed -E "s/## Tables.+//" |  # Delete the end of the file
    tr '\t' '\n' >README.new.md # Replace all tabs with newlines

#==============================================================================
# Matlab tables
#==============================================================================

# Run the matlab scripts if tables don't exist
if [ ! -f ./matlab/_results/tables-tex/table_1.tex ]; then
    matlab -batch "run('matlab/table_1.m')"
fi
if [ ! -f ./matlab/_results/tables-tex/table_2.tex ]; then
    matlab -batch "run('matlab/table_2.m')"
fi

# Insert the new tables
cat <<EOF >>README.new.md
## Tables

### Table 1

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_1.tex)

### Table 2

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_2.tex)
EOF

#==============================================================================
# Post steps
#==============================================================================

# Replace the old README with the new one
mv README.new.md README.md
