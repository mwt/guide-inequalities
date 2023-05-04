#/bin/bash

# Change to the directory of this script
cd "$(git rev-parse --show-toplevel)"

tr '\n' '\t' <README.md |       # Start by replacing all newlines with tabs
    sed -E "s/## Tables.+//" |  # Delete the end of the file
    tr '\t' '\n' >README.new.md # Replace all tabs with newlines

# Insert the new tables
cat <<EOF >>README.new.md
## Tables

### Table 1

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_1.tex)

### Table 2

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_2.tex)
EOF

# Replace the old README with the new one
mv README.new.md README.md
