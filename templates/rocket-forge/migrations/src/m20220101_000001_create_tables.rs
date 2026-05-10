use sea_orm_migration::prelude::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Account::Table)
                    .if_not_exists()
                    .col(ColumnDef::new(Account::Id).uuid().not_null().primary_key())
                    .col(ColumnDef::new(Account::Username).string().not_null())
                    .col(ColumnDef::new(Account::Email).string().not_null())
                    .col(ColumnDef::new(Account::Password).string().not_null())
                    .col(
                        ColumnDef::new(Account::Admin)
                            .boolean()
                            .not_null()
                            .default(false),
                    )
                    .to_owned(),
            )
            .await?;
        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Account::Table).to_owned())
            .await?;
        Ok(())
    }
}

#[derive(DeriveIden)]
enum Account {
    Table,
    Id,
    Username,
    Password,
    Email,
    Admin,
}
