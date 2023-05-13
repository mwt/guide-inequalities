#!/bin/sh
cd "$(dirname -- "$0")"

cat ../r/1_functions/*.R > ineq_functions/shim.R
