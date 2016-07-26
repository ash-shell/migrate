#################################################
# Returns the query for creating the migrations
# table
#################################################
Migrate_create_migrations_table_query(){
    read -d '' sql <<____EOF
    CREATE TABLE $MIGRATE_MIGRATIONS_TABLE (
        id          serial      PRIMARY KEY,
        name        text        NOT NULL UNIQUE,
        ran_last    boolean     NOT NULL DEFAULT false,
        active      boolean     NOT NULL DEFAULT false,
        created_at  bigint      NOT NULL UNIQUE
    );
____EOF
    echo "$sql"
}

#################################################
# Returns the query for creating a new migration
#
# @param $1: The name of the migration
# @param $2: The timestamp of the migration
#################################################
Migrate_create_migration_query(){
    read -d '' sql <<____EOF
    INSERT INTO $MIGRATE_MIGRATIONS_TABLE
    VALUES(DEFAULT, '$1', FALSE, FALSE, $2);
____EOF
    echo "$sql"
}

#################################################
# Returns the query for counting the number of
# migrations that match the name
#
# @param $1: The migration name
#################################################
Migrate_count_migrations_by_name_query(){
    read -d '' sql <<____EOF
    SELECT COUNT(id)
    FROM $MIGRATE_MIGRATIONS_TABLE
    WHERE name='$1';
____EOF
    echo "$sql"
}
