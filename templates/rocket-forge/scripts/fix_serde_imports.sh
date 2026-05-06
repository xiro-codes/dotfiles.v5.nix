#!/bin/bash

# Simple shell script to fix serde imports in sea-orm generated files
# This is a backup solution for systems without Python

models_dir="${1:-./models/src}"

echo "Fixing serde imports in $models_dir..."

for file in "$models_dir"/*.rs; do
    if [[ -f "$file" && "$file" != */lib.rs && "$file" != */prelude.rs ]]; then
        echo "Processing $(basename "$file")..."
        
        # Fix serde imports using sed
        sed -i.bak 's/use serde::{/use rocket::serde::{/g' "$file"
        sed -i.bak 's/use serde::/use rocket::serde::/g' "$file"
        
        # Remove backup files
        rm -f "${file}.bak"
    fi
done

echo "✅ Serde imports fixed!"
echo "⚠️  Note: This script only fixes imports. Manual code preservation requires the Python script."