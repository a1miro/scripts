#!/bin/bash
patches_dir="$1"

for patch in $(ls ${patches_dir}/*.patch | sort -V); do
    git apply --whitespace=fix "$patch"
    echo "applied patch: $patch"
done
