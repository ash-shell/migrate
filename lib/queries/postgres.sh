#################################################
# Echoes the query for creating the migrations
# table
#################################################
Migrate_create_migrations_table_query(){
    read -d '' sql <<____EOF
    CREATE TABLE $MIGRATE_MIGRATIONS_TABLE (
        id          serial      PRIMARY KEY,
        name        text        NOT NULL UNIQUE,
        active      boolean     NOT NULL DEFAULT false,
        created_at  bigint      NOT NULL UNIQUE
    );
____EOF
    echo "$sql"
}
