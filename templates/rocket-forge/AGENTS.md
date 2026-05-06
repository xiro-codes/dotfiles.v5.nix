# Agent Instructions for Rocket Blog Codebase

Welcome to the Rocket Blog and Work Time Tracker project. This document provides essential context, commands, and conventions for AI agents working in this codebase.

## 🏗️ Project Architecture

This is a Rust monolithic application using the **Rocket** web framework and **SeaORM** for database operations. It serves two applications via different binaries: a blog and a work time tracker.

- **Web Framework**: Rocket (`v0.5`)
- **Database**: PostgreSQL (via SeaORM `v1.1.1`)
- **Templating**: MiniJinja via `rocket_dyn_templates` (Files use `.html.j2` extension)
- **Frontend**: Server-Side Rendered (SSR) HTML + Bootstrap
- **Authentication**: Cookie-based securely encrypted tokens
- **Build System**: Cargo + Just

## 📁 Code Organization

The project strictly follows the **Service Layer Pattern**:

- `src/bin/`: Application entry points (`blog.rs` and `worktime.rs`).
- `src/controllers/`: HTTP request handlers (Rocket routes). **Do not put business logic here.**
- `src/services/`: Core business logic and database interactions. Called by controllers.
- `src/guards/`: Rocket request guards (e.g., authentication checks).
- `src/dto/` & `models/src/dto.rs`: Data Transfer Objects (form structures).
- `models/`: Database entities (Managed by SeaORM).
- `migrations/`: Database migrations.
- `templates/`: Jinja2 templates (`.html.j2`).
- `static/`: Static assets (CSS, JS).
- `scripts/`: Development and deployment automation scripts.

## 🛠️ Essential Commands (via `just`)

The project uses [`just`](https://github.com/casey/just) for task running.

### Local Development
- `just build-dev` / `just build`: Build in debug/release mode.
- `just dev` / `just run`: Run the application locally.
- `just test`: Run all tests.
- `just clippy`: Run the clippy linter.
- `just fmt`: Format code.

### Database & Models (SeaORM)
- `just migrate`: Run database migrations.
- `just new-migration NAME`: Create a new migration.
- `just gen-models`: Regenerate SeaORM models. **Gotcha**: Always use this command instead of raw `sea-orm-cli`. It automatically fixes serde imports and preserves the custom `dto` modules.

### NixOS Environment
- `nix build`: Build the application locally.
- `nix develop`: Enter the development shell.
- `nix flake check`: Verify the flake configuration.

## ⚠️ Important Gotchas & Conventions

1. **Service Layer Separation**: 
   - Controllers (`src/controllers/`) should only handle HTTP concerns (request parsing, response formatting).
   - All complex business logic and database queries (`SeaORM` operations) MUST live in `src/services/`.
2. **Generating Models**:
   - If you change the database schema in `migrations/`, run `just migrate` followed by `just gen-models`. 
   - **Do not manually edit** the generated entity files in `models/src/` (e.g., `account.rs`, `post.rs`), as they will be overwritten. Put custom logic or DTOs in `models/src/dto.rs`.
3. **Template Engine**:
   - The project uses **MiniJinja** (`.html.j2`), not Tera, despite what older architecture docs might suggest.
   - Use `| safe` when rendering raw HTML (e.g., markdown output).
4. **Testing**:
   - Tests are located in `src/tests/`. Ensure you run `just test` after making modifications.
   - We use SeaORM mock database capabilities for isolated unit testing.
5. **Async Rust**:
   - Rocket and SeaORM are fully async. Use `async/await` and `tokio` appropriately. 
   - Avoid blocking operations in controllers and services.
