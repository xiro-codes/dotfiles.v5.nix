#!/bin/bash
# Simple script to generate sea-orm entities with dto module preservation
#
# This script:
# 1. Removes existing entity files (but preserves dto.rs)
# 2. Generates new entities with sea-orm-cli
# 3. Fixes serde imports to use rocket::serde
# 4. Ensures the dto.rs module is included in lib.rs

set -e

MODELS_DIR=${1:-"./models/src"}

echo "🧹 Removing existing entity files (preserving dto.rs)..."
# Remove only generated entity files, preserve dto.rs and other custom files
rm -f "$MODELS_DIR"/account.rs "$MODELS_DIR"/comment.rs "$MODELS_DIR"/post.rs "$MODELS_DIR"/prelude.rs "$MODELS_DIR"/lib.rs || true

echo "🚀 Generating new entities..."
sea-orm-cli generate entity -l --model-extra-attributes 'serde(crate="rocket::serde")' --with-serde both --with-copy-enums -o "$MODELS_DIR"

echo "🔧 Fixing serde imports..."
./scripts/fix_serde_imports.sh "$MODELS_DIR"

echo "📦 Adding DTO module to lib.rs..."
# Add dto module to lib.rs if not present
echo "" >> "$MODELS_DIR/lib.rs"
echo "// Custom DTOs and form structures" >> "$MODELS_DIR/lib.rs"
echo "pub mod dto;" >> "$MODELS_DIR/lib.rs"

echo "✅ Models generated successfully with preserved DTO module!"