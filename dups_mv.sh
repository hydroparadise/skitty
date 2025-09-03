#! /bin/bash


INPUT_FILE="$1"
DEST_DIR="$2"

# Declare associative array to store file paths indexed by hash
declare -A hash_map

# Read the input file line by line
while IFS= read -r line; do
    # Split line into hash and path
    IFS=',' read -r hash path <<< "$line"

    # Append the file path to the hash entry in the map
    if [[ -z "${hash_map[$hash]}" ]]; then
        hash_map["$hash"]=$path
    else
        hash_map["$hash"]+=$'\n'"$path"
    fi
done < "$INPUT_FILE"

# Process each hash entry
for hash in "${!hash_map[@]}"; do
    # Split the entry into an array of file paths
    IFS=$'\n' read -d '' -ra paths <<< "${hash_map[$hash]}"
    count=${#paths[@]}

    # If there are duplicates, generate `mv` commands for all but the first
    if (( count > 1 )); then
        for (( i=1; i<count; i++ )); do
            echo "mv \"${paths[i]}\" \"${DEST_DIR}\""
        done
    fi
done

