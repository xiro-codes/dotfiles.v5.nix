# Sea-ORM Entity Generation Automation

This directory contains scripts to automate the sea-orm entity generation process with a clean modular approach.

## New Modular Architecture (Recommended)

**Key Innovation**: Custom code (DTOs, forms, etc.) is now separated into a dedicated `dto.rs` module, eliminating the need for complex code preservation during entity regeneration.

### Benefits
- ✅ Custom code never gets lost during regeneration
- ✅ Clean separation between generated entities and manual code  
- ✅ Simpler maintenance and easier to understand
- ✅ No complex backup/restore logic needed

## Problem

When using `sea-orm-cli generate entity`, the generated code uses `serde::{Deserialize, Serialize}` instead of `rocket::serde::{Deserialize, Serialize}` (required for Rocket integration).

## Solution

### Current Architecture (Clean & Simple)

Custom DTOs and forms are now in `models/src/dto.rs`:
```rust
// models/src/dto.rs
pub struct AccountFormDTO { ... }
pub struct CommentFormDTO { ... } 
pub struct PostTitleResult { ... }
```

Entity files contain only generated code:
```rust
// models/src/account.rs - only generated entity code
pub struct Model { ... }
pub enum Relation { ... }
impl ActiveModelBehavior for ActiveModel {}
```

### Usage

```bash
just gen-models
```

This will:
1. Remove only generated entity files (preserving dto.rs)
2. Regenerate entities with sea-orm-cli
3. Fix serde imports to use rocket::serde  
4. Add the dto module to lib.rs

## Scripts

### generate_models.sh (New Simple Script)

**Usage**:
```bash
./scripts/generate_models.sh [models_dir]
```

**What it does**:
- Regenerates entity files
- Fixes serde imports
- Preserves the dto.rs module

### fix_serde_imports.sh

**Usage**:
```bash
./scripts/fix_serde_imports.sh ./models/src
```

**What it fixes**:
- `use serde::{...}` → `use rocket::serde::{...}`

## Migration from Old Approach

If you have existing entity files with inline custom code, the new `dto.rs` module already contains the extracted DTOs:

- `FormDTO` (from account.rs) → `AccountFormDTO`
- `FormDTO` (from comment.rs) → `CommentFormDTO` 
- `TitleResult` (from post.rs) → `PostTitleResult`

Update your imports:
```rust
// Old
use crate::models::account::FormDTO;

// New  
use crate::models::dto::AccountFormDTO;
```

## Legacy Scripts (Deprecated)

The `preserve_custom_code.py` script has been removed as it's no longer needed with the new modular approach.

## Integration with justfile

- `just gen-models` - Generate entities with DTO module preservation
- `just gen-models-simple` - Same as above (legacy name kept for compatibility)