#!/bin/bash

#################################################
# Tests if a migration is already being tracked
# in the database.
#
# @param $1: The name of the migration
# @return $Ash__TRUE if the query is tracked,
#   $Ash__FALSE otherwise
#################################################
Migrate_is_tracked() {
    local sql=$(Migrate_count_migrations_by_name_query "$1")
    local result="$(Sql__execute "$sql")"

    # If there are already migrations that match the name
    if [[ "$result" -ne 0 ]]; then
        return $Ash__TRUE
    else
        return $Ash__FALSE
    fi
}

#################################################
# Creates a migration from the name and
# timestamp.
#
# @param $1: The name of the migration
# @param $2: The timestamp of the migration
#################################################
Migrate_create_migration() {
    local sql="$(Migrate_create_migration_query "$1" "$2")"
    local result="$(Sql__execute "$sql")"
    if [[ $? -eq 0 ]]; then
        return $Ash__TRUE
    else
        return $Ash__FALSE
    fi
}
