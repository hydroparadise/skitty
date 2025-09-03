#! /bin/bash


find . -type f -print0 | while IFS= read -r -d '' file; do
    # Extract the hash of the file's content using sha256sum
    hash=$(sha256sum "$file" | awk '{print $1}')

    # Get the absolute path without resolving symlinks
    dir=$(dirname "$file")
    base=$(basename "$file")
    abs_dir=$(cd "$dir" && pwd -P 2>/dev/null)
    abs_path="$abs_dir/$base"

    # Output the hash and absolute file path
    printf '%s,%s\n' "$hash" "$abs_path"
done

