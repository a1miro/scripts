#! /bin/bash

# Define short and long options
SHORT_OPTS="hI:O:"
LONG_OPTS="help,include:out-format:"
out_format="dtb"

#usage_message="Usage: $(basename $0) -I <include_paths>... <dts_file>"

read -r -d '' usage_message << EOM
Usage: $(basename $0) -I <include_paths>... <dts_file>
Options:
  -I, --include <include_paths>  Include paths for the DTS file
  -O, --out-format <arg>     
        Output formats are:
                dts - device tree source text
                dtb - device tree blob
                asm - assembler source
  -h, --help                     Display this help message

EOM


# Parse options
PARSED_OPTS=$(getopt --options $SHORT_OPTS --longoptions $LONG_OPTS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Evaluate the parsed options
eval set -- "$PARSED_OPTS"

# Initialize variables
include_paths=()

# Process options
while true; do
    case "$1" in
        -h|--help)
            echo $usage_message
            exit 0
             ;;
        -I|--include)
            include_paths+=("-I$2")
            shift 2
            ;;
        -O|--out-format)
            out_format=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
done

# Handle optionless arguments
dts_file=$@
if [[ $# -eq 0 ]]; then
    echo "Error: DTS file not specified"
    echo $usage_message
    exit 1
fi

echo "DTS file: $dts_file"
echo "Include paths: ${include_paths[@]}"
echo "Output format: $out_format"


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

echo "preprocessing original DTS file ${dts_file}, output written to ${dts_preprocessed}"
cpp -nostdinc ${include_paths} -undef -x assembler-with-cpp ${dts_file} ${dts_preprocessed}

echo "compiling preprocessed dts: dtc -I dts -O dtb -o ${dtb_file} ${dts_preprocessed}"
#dtc -I dts -O fdt -o ${dtb_file} ${dts_preprocessed}
dtc -I dts -O ${out_format} -o ${dtb_file} ${dts_preprocessed}

if [ ! $? -eq "0" ] ; then 
       exit 1
fi

echo "Removing ${dts_preprocessed} file"
rm ${dts_preprocessed}

echo "Successfully finished, ${dtb_file} is created"