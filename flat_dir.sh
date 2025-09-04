#!/bin/bash

# Check if the user provided a destination directory
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <destination_directory>"
    exit 1
fi

dest_dir="$1"

# Check if the destination directory exists
if [ ! -d "$dest_dir" ]; then
    echo "Error: Destination directory '$dest_dir' does not exist."
    exit 1
fi

# Use an associative array to track the count of each base name
declare -A name_counts

# Use null-delimited input to handle filenames with newlines or spaces
while IFS= read -r -d '' file; do
    # Extract the filename without the path
    filename="${file##*/}"

    # Split into base name and extension
    base="${filename%.*}"
    ext="${filename##*.}"

    # Check if the file has an extension
    if [[ "$filename" == *.* ]]; then
        ext=".$ext"
    else
        ext=""
    fi

    # Get the current count for this base name
    count=${name_counts["$base"]:-0}

    # Generate the new name
    if [ "$count" -eq 0 ]; then
        new_name="$base$ext"
    else
        new_name="$base$count$ext"
    fi

    # Increment the count for the next occurrence of this base name
    ((name_counts["$base"]++))

    # Move the file to the destination
    mv "$file" "$dest_dir/$new_name"
done < <(find . -type f -print0)

