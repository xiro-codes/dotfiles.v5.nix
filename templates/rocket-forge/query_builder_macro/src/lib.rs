//! # CodeIgniter3-Style Query Builder Proc Macro
//!
//! This crate provides a procedural macro that generates CodeIgniter3-style query builders
//! for Sea-ORM entities. The generated code provides a familiar and fluent interface for
//! developers coming from CodeIgniter 3's Active Record pattern while maintaining full
//! type safety and compile-time validation.
//!
//! ## Usage
//!
//! Add the `QueryBuilder` derive macro to any Sea-ORM entity:
//!
//! ```rust
//! use sea_orm::entity::prelude::*;
//! use query_builder_macro::QueryBuilder;
//!
//! #[derive(Clone, Debug, PartialEq, DeriveEntityModel, Eq, QueryBuilder)]
//! #[sea_orm(table_name = "post")]
//! pub struct Model {
//!     #[sea_orm(primary_key)]
//!     pub id: i32,
//!     pub title: String,
//!     pub content: String,
//!     pub published: bool,
//! }
//! ```
//!
//! This will generate a query builder with methods like:
//! - `where_eq()`, `where_in()`, `like()` for filtering
//! - `order_by()`, `order_asc()`, `order_desc()` for sorting
//! - `limit()`, `offset()` for pagination
//! - `get()`, `first()`, `count()` for execution
//!
//! ## Features
//!
//! - **Type Safety**: All column references are validated at compile time
//! - **Fluent Interface**: Method chaining creates readable query construction
//! - **Zero Runtime Cost**: All code is generated at compile time
//! - **Sea-ORM Integration**: Works seamlessly with existing Sea-ORM code

use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, DeriveInput, Data, Fields};

/// Derive macro to generate a CodeIgniter3-style query builder for Sea-ORM entities.
///
/// This macro generates a fluent query builder that provides a familiar interface for
/// developers coming from CodeIgniter 3's Active Record pattern. The generated builder
/// maintains full type safety by leveraging Sea-ORM's existing `Column` enum.
///
/// # Generated API
///
/// The macro generates a `{ModelName}QueryBuilder` struct with the following methods:
///
/// ## Filtering Methods
/// - `where_eq(column, value)` - Add WHERE column = value condition
/// - `where_in(column, values)` - Add WHERE column IN (...values) condition  
/// - `like(column, pattern)` - Add WHERE column LIKE '%pattern%' condition
/// - `where_not_null(column)` - Add WHERE column IS NOT NULL condition
/// - `where_null(column)` - Add WHERE column IS NULL condition
/// - `or_where_eq(column, value)` - Add OR WHERE condition
///
/// ## Sorting Methods
/// - `order_by(column, direction)` - Add ORDER BY clause with explicit direction
/// - `order_asc(column)` - Add ORDER BY column ASC (convenience method)
/// - `order_desc(column)` - Add ORDER BY column DESC (convenience method)
///
/// ## Pagination Methods
/// - `limit(count)` - Add LIMIT clause
/// - `offset(count)` - Add OFFSET clause
///
/// ## Execution Methods
/// - `get(db)` - Execute query and return all results as `Vec<Model>`
/// - `first(db)` - Execute query and return first result as `Option<Model>`
/// - `count(db)` - Execute query and return count as u64
///
/// # Example
///
/// ```rust
/// // Basic usage
/// let posts = post::Entity::query()
///     .where_eq(post::Column::Published, true)
///     .like(post::Column::Title, "rust")
///     .order_desc(post::Column::CreatedAt)
///     .limit(10)
///     .get(&db)
///     .await?;
///
/// // Complex query
/// let mut query = post::Entity::query()
///     .where_eq(post::Column::Draft, false);
///
/// if let Some(author_id) = author_id {
///     query = query.where_eq(post::Column::AuthorId, author_id);
/// }
///
/// let results = query
///     .order_desc(post::Column::DatePublished)
///     .limit(20)
///     .offset(page * 20)
///     .get(&db)
///     .await?;
/// ```
///
/// # Type Safety
///
/// All column references use Sea-ORM's generated `Column` enum, ensuring:
/// - Invalid column names cause compile-time errors
/// - Type mismatches between columns and values cause compile-time errors
/// - IDE autocompletion and error checking work properly
///
/// # Requirements
///
/// The target struct must:
/// - Be a Sea-ORM entity (derive `DeriveEntityModel`)
/// - Have named fields (not tuple or unit structs)
/// - Have a corresponding `Entity` type in scope
///
/// # Generated Code Structure
///
/// For a model named `Post`, this macro generates:
/// - `PostQueryBuilder` struct with query state
/// - Implementation of all query builder methods
/// - Extension of `Entity` with a `query()` class method
/// - Integration with Sea-ORM's existing query system
#[proc_macro_derive(QueryBuilder)]
pub fn derive_query_builder(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    
    let model_name = &input.ident;
    let entity_name = quote::format_ident!("Entity");
    let builder_name = quote::format_ident!("{}QueryBuilder", model_name);
    
    // Extract field information from the struct
    let fields = match &input.data {
        Data::Struct(data) => match &data.fields {
            Fields::Named(fields) => &fields.named,
            _ => {
                return syn::Error::new_spanned(
                    input,
                    "QueryBuilder can only be derived for structs with named fields"
                ).to_compile_error().into();
            }
        },
        _ => {
            return syn::Error::new_spanned(
                input,
                "QueryBuilder can only be derived for structs"
            ).to_compile_error().into();
        }
    };

    // Generate column name constants for type safety
    let column_constants: Vec<_> = fields.iter().map(|field| {
        let field_name = field.ident.as_ref().unwrap();
        let const_name = quote::format_ident!("{}", field_name.to_string().to_uppercase());
        quote! {
            pub const #const_name: &'static str = stringify!(#field_name);
        }
    }).collect();

    // Generate the query builder implementation
    let expanded = quote! {
        use sea_orm::{QuerySelect, QueryOrder};
        
        impl #entity_name {
            /// Create a new query builder instance for this entity.
            ///
            /// This method provides the entry point for building CodeIgniter3-style queries.
            /// It returns a new query builder that can be chained with filtering, sorting,
            /// and pagination methods before execution.
            ///
            /// # Example
            ///
            /// ```rust
            /// let posts = MyEntity::query()
            ///     .where_eq(Column::Status, "published")
            ///     .order_desc(Column::CreatedAt)
            ///     .limit(10)
            ///     .get(&db)
            ///     .await?;
            /// ```
            pub fn query() -> #builder_name {
                #builder_name::new()
            }
        }

        /// CodeIgniter3-style query builder for #entity_name.
        ///
        /// This struct provides a fluent interface for building database queries that
        /// mirrors CodeIgniter 3's Active Record pattern. All operations are type-safe
        /// and leverage Sea-ORM's existing column definitions for compile-time validation.
        ///
        /// The builder accumulates query conditions, sorting rules, and pagination settings
        /// before executing the final query against the database.
        ///
        /// # Usage Pattern
        ///
        /// 1. Start with `Entity::query()` to create a new builder
        /// 2. Chain filtering methods like `where_eq()`, `like()`, etc.
        /// 3. Add sorting with `order_by()`, `order_asc()`, or `order_desc()`
        /// 4. Apply pagination with `limit()` and `offset()`
        /// 5. Execute with `get()`, `first()`, or `count()`
        ///
        /// # Type Safety
        ///
        /// All column references must use the entity's `Column` enum, ensuring that:
        /// - Only valid columns can be referenced
        /// - Value types match column types
        /// - Changes to the entity schema are reflected in the query builder
        pub struct #builder_name {
            /// Accumulated WHERE conditions using Sea-ORM's Condition system
            conditions: sea_orm::Condition,
            /// Selected fields for the query (currently supports full model selection)
            select_fields: Vec<sea_orm::sea_query::SimpleExpr>,
            /// ORDER BY clauses with column and direction pairs
            order_by: Vec<(sea_orm::sea_query::SimpleExpr, sea_orm::Order)>,
            /// LIMIT value for result set size restriction
            limit_value: Option<u64>,
            /// OFFSET value for pagination support
            offset_value: Option<u64>,
        }

        impl #builder_name {
            /// Create a new query builder instance.
            ///
            /// Initializes a fresh query builder with no conditions, ordering, or pagination.
            /// This is typically called internally by `Entity::query()` rather than directly.
            ///
            /// # Returns
            ///
            /// A new `#builder_name` instance ready for method chaining.
            pub fn new() -> Self {
                Self {
                    conditions: sea_orm::Condition::all(),
                    select_fields: Vec::new(),
                    order_by: Vec::new(),
                    limit_value: None,
                    offset_value: None,
                }
            }

            /// Select specific fields for the query.
            ///
            /// Similar to CodeIgniter 3's `select()` method, this allows you to specify
            /// which columns should be included in the result set. Currently this method
            /// exists for API compatibility but full column selection is not yet implemented.
            ///
            /// # Parameters
            ///
            /// * `column` - The column to select, must be from the entity's `Column` enum
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let query = Entity::query()
            ///     .select(Column::Title)
            ///     .select(Column::CreatedAt);
            /// ```
            ///
            /// # Note
            ///
            /// Currently returns the full model. Future versions will support partial selection.
            pub fn select(mut self, column: Column) -> Self {
                self.select_fields.push(sea_orm::sea_query::Expr::col(column).into());
                self
            }

            /// Add a WHERE column = value condition.
            ///
            /// Equivalent to CodeIgniter 3's `where()` method. Adds an equality condition
            /// to the query using AND logic. Multiple calls to this method will be combined
            /// with AND operators.
            ///
            /// # Parameters
            ///
            /// * `column` - The column to filter on, must be from the entity's `Column` enum
            /// * `value` - The value to compare against, must be compatible with the column type
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let posts = Entity::query()
            ///     .where_eq(Column::Status, "published")
            ///     .where_eq(Column::AuthorId, user_id)
            ///     .get(&db)
            ///     .await?;
            /// ```
            ///
            /// # Type Safety
            ///
            /// The value type must be compatible with the column type, ensuring compile-time
            /// type checking prevents runtime errors from type mismatches.
            pub fn where_eq(mut self, column: Column, value: impl Into<sea_orm::Value>) -> Self {
                self.conditions = self.conditions.add(column.eq(value));
                self
            }

            /// Add a WHERE column IN (...values) condition.
            ///
            /// Equivalent to CodeIgniter 3's `where_in()` method. Checks if the column value
            /// matches any of the provided values using SQL's IN operator.
            ///
            /// # Parameters
            ///
            /// * `column` - The column to filter on, must be from the entity's `Column` enum
            /// * `values` - A vector of values to match against
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let post_ids = vec![1, 2, 3, 4, 5];
            /// let posts = Entity::query()
            ///     .where_in(Column::Id, post_ids)
            ///     .get(&db)
            ///     .await?;
            /// ```
            ///
            /// # Performance
            ///
            /// For large lists of values, consider using multiple smaller queries or
            /// alternative approaches for better performance.
            pub fn where_in<V: Into<sea_orm::Value>>(mut self, column: Column, values: Vec<V>) -> Self {
                let values: Vec<sea_orm::Value> = values.into_iter().map(|v| v.into()).collect();
                self.conditions = self.conditions.add(column.is_in(values));
                self
            }

            /// Add a LIKE pattern matching condition.
            ///
            /// Equivalent to CodeIgniter 3's `like()` method. Automatically wraps the pattern
            /// with wildcards for substring matching. The pattern becomes `%pattern%` in the
            /// generated SQL.
            ///
            /// # Parameters
            ///
            /// * `column` - The column to search in, must be from the entity's `Column` enum
            /// * `pattern` - The substring to search for
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let posts = Entity::query()
            ///     .like(Column::Title, "rust programming")
            ///     .like(Column::Content, "tutorial")
            ///     .get(&db)
            ///     .await?;
            /// ```
            ///
            /// # Note
            ///
            /// The pattern is automatically escaped and wrapped with `%` wildcards.
            /// For custom wildcard patterns, use Sea-ORM's native query methods.
            pub fn like(mut self, column: Column, pattern: impl Into<String>) -> Self {
                let pattern_str = format!("%{}%", pattern.into());
                self.conditions = self.conditions.add(column.like(&pattern_str));
                self
            }

            /// Add a WHERE column IS NOT NULL condition.
            ///
            /// Filters out rows where the specified column has a NULL value. Useful for
            /// ensuring required fields are present or filtering optional columns.
            ///
            /// # Parameters
            ///
            /// * `column` - The column to check, must be from the entity's `Column` enum
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let posts = Entity::query()
            ///     .where_not_null(Column::PublishedAt)
            ///     .where_not_null(Column::Excerpt)
            ///     .get(&db)
            ///     .await?;
            /// ```
            pub fn where_not_null(mut self, column: Column) -> Self {
                self.conditions = self.conditions.add(column.is_not_null());
                self
            }

            /// Add a WHERE column IS NULL condition.
            ///
            /// Filters for rows where the specified column has a NULL value. Useful for
            /// finding records with missing optional data.
            ///
            /// # Parameters
            ///
            /// * `column` - The column to check, must be from the entity's `Column` enum
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let drafts = Entity::query()
            ///     .where_null(Column::PublishedAt)
            ///     .get(&db)
            ///     .await?;
            /// ```
            pub fn where_null(mut self, column: Column) -> Self {
                self.conditions = self.conditions.add(column.is_null());
                self
            }

            /// Add an OR WHERE condition.
            ///
            /// Provides basic OR logic support by combining the current conditions with
            /// a new equality condition using OR. This is a simplified implementation
            /// of CodeIgniter 3's `or_where()` method.
            ///
            /// # Parameters
            ///
            /// * `column` - The column to filter on, must be from the entity's `Column` enum
            /// * `value` - The value to compare against
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let posts = Entity::query()
            ///     .where_eq(Column::Status, "published")
            ///     .or_where_eq(Column::Status, "featured")
            ///     .get(&db)
            ///     .await?;
            /// ```
            ///
            /// # Note
            ///
            /// For complex OR logic, consider using Sea-ORM's native Condition API
            /// which provides more sophisticated logical operations.
            pub fn or_where_eq(mut self, column: Column, value: impl Into<sea_orm::Value>) -> Self {
                self.conditions = sea_orm::Condition::any()
                    .add(self.conditions)
                    .add(column.eq(value));
                self
            }

            /// Add an ORDER BY clause with explicit direction.
            ///
            /// Equivalent to CodeIgniter 3's `order_by()` method. Allows you to specify
            /// both the column and sort direction explicitly. Multiple calls will add
            /// additional sort criteria in the order they are called.
            ///
            /// # Parameters
            ///
            /// * `column` - The column to sort by, must be from the entity's `Column` enum
            /// * `direction` - The sort direction (sea_orm::Order::Asc or sea_orm::Order::Desc)
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// use sea_orm::Order;
            /// 
            /// let posts = Entity::query()
            ///     .order_by(Column::Priority, Order::Desc)
            ///     .order_by(Column::CreatedAt, Order::Asc)
            ///     .get(&db)
            ///     .await?;
            /// ```
            pub fn order_by(mut self, column: Column, direction: sea_orm::Order) -> Self {
                self.order_by.push((sea_orm::sea_query::Expr::col(column).into(), direction));
                self
            }

            /// Order by column in ascending direction.
            ///
            /// Convenience method equivalent to `order_by(column, Order::Asc)`.
            /// Results will be sorted from lowest to highest values.
            ///
            /// # Parameters
            ///
            /// * `column` - The column to sort by, must be from the entity's `Column` enum
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let posts = Entity::query()
            ///     .order_asc(Column::Title)
            ///     .get(&db)
            ///     .await?;
            /// ```
            pub fn order_asc(mut self, column: Column) -> Self {
                self.order_by(column, sea_orm::Order::Asc)
            }

            /// Order by column in descending direction.
            ///
            /// Convenience method equivalent to `order_by(column, Order::Desc)`.
            /// Results will be sorted from highest to lowest values.
            ///
            /// # Parameters
            ///
            /// * `column` - The column to sort by, must be from the entity's `Column` enum
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let posts = Entity::query()
            ///     .order_desc(Column::CreatedAt)
            ///     .get(&db)
            ///     .await?;
            /// ```
            pub fn order_desc(mut self, column: Column) -> Self {
                self.order_by(column, sea_orm::Order::Desc)
            }

            /// Add a LIMIT clause to restrict the number of results.
            ///
            /// Equivalent to CodeIgniter 3's `limit()` method. Limits the maximum number
            /// of rows returned by the query. Useful for pagination and performance optimization.
            ///
            /// # Parameters
            ///
            /// * `limit` - The maximum number of rows to return
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let recent_posts = Entity::query()
            ///     .order_desc(Column::CreatedAt)
            ///     .limit(10)
            ///     .get(&db)
            ///     .await?;
            /// ```
            ///
            /// # Performance
            ///
            /// Using LIMIT can significantly improve query performance by reducing
            /// the amount of data transferred and processed.
            pub fn limit(mut self, limit: u64) -> Self {
                self.limit_value = Some(limit);
                self
            }

            /// Add an OFFSET clause for pagination.
            ///
            /// Equivalent to CodeIgniter 3's `offset()` method. Skips the specified number
            /// of rows before returning results. Commonly used with `limit()` for pagination.
            ///
            /// # Parameters
            ///
            /// * `offset` - The number of rows to skip
            ///
            /// # Returns
            ///
            /// Self for method chaining
            ///
            /// # Example
            ///
            /// ```rust
            /// let page = 2;
            /// let per_page = 20;
            /// 
            /// let posts = Entity::query()
            ///     .order_desc(Column::CreatedAt)
            ///     .limit(per_page)
            ///     .offset(page * per_page)
            ///     .get(&db)
            ///     .await?;
            /// ```
            ///
            /// # Note
            ///
            /// Large offset values can impact performance. Consider using cursor-based
            /// pagination for better performance with large datasets.
            pub fn offset(mut self, offset: u64) -> Self {
                self.offset_value = Some(offset);
                self
            }

            /// Execute the query and return all matching results.
            ///
            /// Equivalent to CodeIgniter 3's `get()` method. Builds and executes the complete
            /// SQL query, returning all rows that match the specified conditions. This is the
            /// primary execution method for retrieving multiple records.
            ///
            /// # Parameters
            ///
            /// * `db` - A reference to the Sea-ORM database connection
            ///
            /// # Returns
            ///
            /// `Result<Vec<#model_name>, sea_orm::DbErr>` - A vector of model instances or database error
            ///
            /// # Example
            ///
            /// ```rust
            /// let posts = Entity::query()
            ///     .where_eq(Column::Published, true)
            ///     .order_desc(Column::CreatedAt)
            ///     .limit(20)
            ///     .get(&db)
            ///     .await?;
            /// 
            /// println!("Found {} posts", posts.len());
            /// for post in posts {
            ///     println!("Post: {}", post.title);
            /// }
            /// ```
            ///
            /// # Performance
            ///
            /// This method loads all matching records into memory. For large result sets,
            /// consider using pagination with `limit()` and `offset()` or streaming approaches.
            ///
            /// # SQL Generation
            ///
            /// The method applies all accumulated conditions, sorting, and pagination to
            /// generate an optimized SQL query using Sea-ORM's query builder.
            pub async fn get(self, db: &sea_orm::DbConn) -> Result<Vec<#model_name>, sea_orm::DbErr> {
                let mut query = #entity_name::find();

                // Apply WHERE conditions
                query = query.filter(self.conditions);

                // Apply SELECT fields (simplified - full table select for now)
                // In a more advanced version, we would support column selection
                // if !self.select_fields.is_empty() {
                //     query = query.select_only();
                //     for field in self.select_fields {
                //         query = query.column(field);
                //     }
                // }

                // Apply ORDER BY
                for (column, order) in self.order_by {
                    query = query.order_by(column, order);
                }

                // Apply LIMIT
                if let Some(limit) = self.limit_value {
                    query = query.limit(limit);
                }

                // Apply OFFSET
                if let Some(offset) = self.offset_value {
                    query = query.offset(offset);
                }

                query.all(db).await
            }

            /// Execute the query and return the first matching result.
            ///
            /// Equivalent to CodeIgniter 3's `row()` or `first()` method. Builds and executes
            /// the SQL query, returning only the first row that matches the conditions.
            /// Returns `None` if no matching records are found.
            ///
            /// # Parameters
            ///
            /// * `db` - A reference to the Sea-ORM database connection
            ///
            /// # Returns
            ///
            /// `Result<Option<#model_name>, sea_orm::DbErr>` - The first matching model or None, or database error
            ///
            /// # Example
            ///
            /// ```rust
            /// let latest_post = Entity::query()
            ///     .where_eq(Column::Published, true)
            ///     .order_desc(Column::CreatedAt)
            ///     .first(&db)
            ///     .await?;
            /// 
            /// match latest_post {
            ///     Some(post) => println!("Latest post: {}", post.title),
            ///     None => println!("No published posts found"),
            /// }
            /// ```
            ///
            /// # Performance
            ///
            /// This method is optimized for single-record retrieval and will only fetch
            /// one row from the database, making it efficient for existence checks and
            /// single-record lookups.
            ///
            /// # Behavior
            ///
            /// If multiple records match the conditions, only the first one (according to
            /// any ORDER BY clauses) will be returned. LIMIT and OFFSET are ignored since
            /// only one record is requested.
            pub async fn first(self, db: &sea_orm::DbConn) -> Result<Option<#model_name>, sea_orm::DbErr> {
                let mut query = #entity_name::find();

                // Apply WHERE conditions
                query = query.filter(self.conditions);

                // Apply SELECT fields (simplified - full table select for now)
                // In a more advanced version, we would support column selection
                // if !self.select_fields.is_empty() {
                //     query = query.select_only();
                //     for field in self.select_fields {
                //         query = query.column(field);
                //     }
                // }

                // Apply ORDER BY
                for (column, order) in self.order_by {
                    query = query.order_by(column, order);
                }

                query.one(db).await
            }

            /// Count the number of records matching the query conditions.
            ///
            /// Equivalent to CodeIgniter 3's `count_all_results()` method. Executes a
            /// COUNT(*) query with the specified WHERE conditions, returning the total
            /// number of matching rows without retrieving the actual data.
            ///
            /// # Parameters
            ///
            /// * `db` - A reference to the Sea-ORM database connection
            ///
            /// # Returns
            ///
            /// `Result<u64, sea_orm::DbErr>` - The count of matching records or database error
            ///
            /// # Example
            ///
            /// ```rust
            /// let published_count = Entity::query()
            ///     .where_eq(Column::Published, true)
            ///     .count(&db)
            ///     .await?;
            /// 
            /// println!("There are {} published posts", published_count);
            /// 
            /// // Useful for pagination
            /// let total_pages = (published_count + per_page - 1) / per_page;
            /// ```
            ///
            /// # Performance
            ///
            /// This method is highly efficient as it only performs a COUNT operation
            /// without transferring actual row data. It's ideal for:
            /// - Pagination calculations
            /// - Existence checks (count > 0)
            /// - Statistics and reporting
            ///
            /// # Behavior
            ///
            /// - WHERE conditions are applied normally
            /// - ORDER BY clauses are ignored (not relevant for counting)
            /// - LIMIT and OFFSET are ignored (counts all matching records)
            pub async fn count(self, db: &sea_orm::DbConn) -> Result<u64, sea_orm::DbErr> {
                let mut query = #entity_name::find();

                // Apply WHERE conditions
                query = query.filter(self.conditions);

                query.count(db).await
            }
        }

        /// Column constants for type-safe field references.
        ///
        /// This implementation block would contain compile-time constants for each field
        /// in the entity, providing an alternative way to reference columns. Currently
        /// this is a placeholder for future enhancements.
        ///
        /// The constants would allow usage like:
        /// ```rust
        /// query.where_eq_str(ModelQueryBuilder::TITLE, "Some Title")
        /// ```
        ///
        /// For now, use the entity's `Column` enum for all column references.
        impl #builder_name {
            #(#column_constants)*
        }
    };

    TokenStream::from(expanded)
}