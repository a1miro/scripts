#! /bin/bash

dts_file=$1

# Extract the path
dts_dir=$(dirname "$dts_file")

# Extract the full basename
dts_basename=$(basename "$dts_file")

# Extract the extension
dts_extension="${dts_file##*.}"

# Extract the basename without the extension
dts_basename_no_ext="${dts_file%.*}"

# DTS CPP preprocessed file
dts_preprocessed="${dts_basename_no_ext}.preprocessed.${dts_extension}"
dtb_file="${dts_basename_no_ext}.dtb"

echo "DTS file: $dts_file"
echo "DTS file path: $dts_dir"
echo "Full basename: $dts_basename"
echo "Extension: $dts_extension"
echo "Basename without extension: $dts_basename_no_ext"


kernel_inc_path=${HOME}/projects/cl-som-imx8/build/tmp/work-shared/cl-som-imx8/kernel-source/include
fs_dts_path=../freescale

echo "preprocessing original DTS file ${dts_file}, output written to ${dts_preprocessed}"
cpp -nostdinc -I${kernel_inc_path} -I${fs_dts_path} -undef -x assembler-with-cpp ${dts_file} ${dts_preprocessed}

echo "compiling preprocessed dts: dtc -I dts -O dtb -o ${dtb_file} ${dts_preprocessed}"
dtc -I dts -O fdt -o ${dtb_file} ${dts_preprocessed}

if [ ! $? -eq "0" ] ; then 
       exit 1
fi       

echo "Removing ${dts_preprocessed} file"
rm ${dts_preprocessed}

echo "Successfully finished, ${dtb_file} is created"

