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
if [ ! -f ./matlab/_results/tables-tex/table_1a.tex ]; then
    matlab -batch "run('matlab/table_1a.m')"
fi
if [ ! -f ./matlab/_results/tables-tex/table_1b.tex ]; then
    matlab -batch "run('matlab/table_1b.m')"
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

## R
if [ ! -f ./r/_results/tables-tex/table_1a.tex ]; then
    cd 'r' && {
        Rscript --vanilla "table_1a.R"
        cd -
    }
fi
if [ ! -f ./r/_results/tables-tex/table_1b.tex ]; then
    cd 'r' && {
        Rscript --vanilla "table_1b.R"
        cd -
    }
fi
if [ ! -f ./r/_results/tables-tex/table_2.tex ]; then
    cd 'r' && {
        Rscript --vanilla "table_2.R"
        cd -
    }
fi
if [ ! -f ./r/_results/tables-tex/table_4.tex ]; then
    cd 'r' && {
        Rscript --vanilla "table_4.R"
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
if [ ! -f ./python/_results/tables-tex/table_1a.tex ]; then
    cd 'python' && {
        source .venv/bin/activate
        python3 "table_1a.py"
        deactivate
        cd -
    } || echo "Maybe there is a problem with the python venv? Try deleting it and running this script again."
fi
if [ ! -f ./python/_results/tables-tex/table_1b.tex ]; then
    cd 'python' && {
        source .venv/bin/activate
        python3 "table_1b.py"
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

# Table convert function
table_to_md() {
    pandoc -f latex -t gfm "$1" |
        sed -e 's/\\(/$/g' -e 's/\\)/$/g'
}

# Insert the new tables
cat <<EOF >>README.md

### Matlab tables

#### Table 1

##### Panel A

$(table_to_md ./matlab/_results/tables-tex/table_1a.tex)

##### Panel B

$(table_to_md ./matlab/_results/tables-tex/table_1b.tex)

#### Table 2

$(table_to_md ./matlab/_results/tables-tex/table_2.tex)

#### Table 3

$(table_to_md ./matlab/_results/tables-tex/table_3.tex)

#### Table 4

$(table_to_md ./matlab/_results/tables-tex/table_4.tex)

### R tables

#### Table 1

##### Panel A

$(table_to_md ./r/_results/tables-tex/table_1a.tex)

##### Panel B

$(table_to_md ./r/_results/tables-tex/table_1b.tex)

#### Table 2

$(table_to_md ./r/_results/tables-tex/table_2.tex)

#### Table 4

$(table_to_md ./r/_results/tables-tex/table_4.tex)

### Python tables

#### Table 1

##### Panel A

$(table_to_md ./python/_results/tables-tex/table_1a.tex)

##### Panel B

$(table_to_md ./python/_results/tables-tex/table_1b.tex)

#### Table 2

$(table_to_md ./python/_results/tables-tex/table_2.tex)

#### Table 3

$(table_to_md ./python/_results/tables-tex/table_3.tex)

#### Table 4

$(table_to_md ./python/_results/tables-tex/table_4.tex)

EOF
