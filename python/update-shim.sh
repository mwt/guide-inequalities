#!/bin/sh
cd "$(dirname -- "$0")"

cat ../r/1_functions/cvalue_*.R > ineq_functions/shim.R
