#################################################
# Echoes the query for creating the migrations
# table
#################################################
Migrate_create_migrations_table_query(){
    read -d '' sql <<____EOF
    CREATE TABLE $MIGRATE_MIGRATIONS_TABLE (
        id          int             UNSIGNED NOT NULL AUTO_INCREMENT,
        name        varchar(100)    NOT NULL,
        active      boolean         NOT NULL DEFAULT false,
        created_at  bigint          NOT NULL,
        PRIMARY KEY(id),
        UNIQUE(name, created_at)
    );
____EOF
    echo "$sql"
}
