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
if [ ! -f ./matlab/_results/tables-tex/table_3.tex ]; then
    matlab -batch "run('matlab/table_3.m')"
fi
if [ ! -f ./matlab/_results/tables-tex/table_4.tex ]; then
    matlab -batch "run('matlab/table_4.m')"
fi
if [ ! -f ./matlab/_results/tables-tex/table_b2.tex ]; then
    matlab -batch "run('matlab/table_b2.m')"
fi

## R
if [ ! -f ./r/_results/tables-tex/table_1.tex ]; then
    cd 'r' && {
        Rscript --vanilla "table_1.R"
        cd -
    }
fi
if [ ! -f ./r/_results/tables-tex/table_2.tex ]; then
    cd 'r' && {
        Rscript --vanilla "table_2.R"
        cd -
    }
fi

## Python
# Create venv if it doesn't exist
if [ ! -d ./python/.venv ]; then
    echo "Creating python Virtual Environment (venv)"
    cd 'python' && {
        python3 -m venv .venv
        source .venv/bin/activate
        pip install -r requirements.txt
        deactivate
        cd -
    }
fi

# Run the python scripts if tables don't exist
if [ ! -f ./python/_results/tables-tex/table_1.tex ]; then
    cd 'python' && {
        source .venv/bin/activate
        python3 "table_1.py"
        deactivate
        cd -
    } || echo "Maybe there is a problem with the python venv? Try deleting it and running this script again."
fi
if [ ! -f ./python/_results/tables-tex/table_2.tex ]; then
    cd 'python' && {
        source .venv/bin/activate
        python3 "table_2.py"
        deactivate
        cd -
    } || echo "Maybe there is a problem with the python venv? Try deleting it and running this script again."
fi
if [ ! -f ./python/_results/tables-tex/table_3.tex ]; then
    cd 'python' && {
        source .venv/bin/activate
        python3 "table_3.py"
        deactivate
        cd -
    } || echo "Maybe there is a problem with the python venv? Try deleting it and running this script again."
fi
if [ ! -f ./python/_results/tables-tex/table_4.tex ]; then
    cd 'python' && {
        source .venv/bin/activate
        python3 "table_4.py"
        deactivate
        cd -
    } || echo "Maybe there is a problem with the python venv? Try deleting it and running this script again."
fi

# Insert the new tables
cat <<EOF >>README.md

### Matlab tables

#### Table 1

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_1.tex)

#### Table 2

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_2.tex)

#### Table 3

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_3.tex)

#### Table 4

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_4.tex)

#### Table B2

$(pandoc -f latex -t gfm ./matlab/_results/tables-tex/table_b2.tex)

### R tables

#### Table 1

$(pandoc -f latex -t gfm ./r/_results/tables-tex/table_1.tex)

#### Table 2

$(pandoc -f latex -t gfm ./r/_results/tables-tex/table_2.tex)

### Python tables

#### Table 1

$(pandoc -f latex -t gfm ./python/_results/tables-tex/table_1.tex)

#### Table 2

$(pandoc -f latex -t gfm ./python/_results/tables-tex/table_2.tex)

#### Table 3

$(pandoc -f latex -t gfm ./python/_results/tables-tex/table_3.tex)

#### Table 4

$(pandoc -f latex -t gfm ./python/_results/tables-tex/table_4.tex)

EOF
