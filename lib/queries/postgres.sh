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

#################################################
# Echoes the query for creating a new migration
#
# @param $1: The name of the migration
# @param $2: The timestamp of the migration
#################################################
Migrate_create_migration_query(){
    read -d '' sql <<____EOF
    INSERT INTO $MIGRATE_MIGRATIONS_TABLE
    VALUES(DEFAULT, '$1', FALSE, $2);
____EOF
    echo "$sql"
}

#################################################
# Echoes the query for counting the number of
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

#################################################
# Echoes the query for getting all migrations
# that are currently in the database.
#################################################
Migrate_select_all_migrations_asc_query(){
    read -d '' sql <<____EOF
    SELECT *
    FROM $MIGRATE_MIGRATIONS_TABLE
    ORDER BY created_at;
____EOF
    echo "$sql"
}

#################################################
# Echoes the query for getting all migrations
# that are currently in the database, in
# descending order.
#################################################
Migrate_select_all_migrations_desc_query(){
    read -d '' sql <<____EOF
    SELECT *
    FROM $MIGRATE_MIGRATIONS_TABLE
    ORDER BY created_at DESC;
____EOF
    echo "$sql"
}

#################################################
# Echoes the query for updating a migrations
# active field
#
# @param $1: The id of the migration
# @param $2: The new value of the active field
#################################################
Migrate_set_active_query(){
    read -d '' sql <<____EOF
    UPDATE $MIGRATE_MIGRATIONS_TABLE
    SET active='$2'
    WHERE id=$1;
____EOF
    echo "$sql"
}
