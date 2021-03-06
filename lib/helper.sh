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
# @return $Ash__TRUE if the migration is created,
#   $Ash__FALSE otherwise
# @echo: The SQL error, in the event there is one
#################################################
Migrate_create_migration() {
    local sql="$(Migrate_create_migration_query "$1" "$2")"
    local result=""
    result="$(Sql__execute "$sql")"
    if [[ $? -eq 0 ]]; then
        return $Ash__TRUE
    else
        echo "$result"
        return $Ash__FALSE
    fi
}

#################################################
# Runs a single migration.
#
# @param $1: The id of the migration
# @param $2: The name of the migration
# @param $3: The timestamp of the migration
#################################################
Migrate_run_migration() {
    local file="$Migrate_MIGRATIONS_CURRENT_DIRECTORY/$3_$2.sql"
    local contents=$(cat $file)
    local migrate_regex=".*--\ Migrate:(.*)--\ Revert:.*"

    # Verify our migration file matches regex
    if [[ ! "$contents" =~ $migrate_regex ]]; then
        echo "Migration file is misformatted"
        return $Ash__FALSE
    fi

    # Get Migration SQL
    migration="${BASH_REMATCH[1]}"
    if [[ "$migration" = "" ]]; then
         echo "Can't run an empty migration"
         return $Ash__FALSE
    fi

    # Run Migration
    local result=""
    result="$(Sql__execute "$migration")"
    if [[ $? -ne $Ash__TRUE ]]; then
        echo "$result"
        return $Ash__FALSE
    fi

    # Update `active` field for query just ran
    local sql="$(Migrate_set_active_query "$1" "$Sql__TRUE")"
    result="$(Sql__execute "$sql")"
    if [[ $? -ne $Ash__TRUE ]]; then
        echo "$result"
        return $Ash__FALSE
    fi
}

#################################################
# Runs a single revert.
#
# @param $1: The id of the migration
# @param $2: The name of the migration
# @param $3: The timestamp of the migration
#################################################
Migrate_run_revert() {
    local file="$Migrate_MIGRATIONS_CURRENT_DIRECTORY/$3_$2.sql"
    local contents=$(cat $file)
    local revert_regex=".*--\ Migrate:.*--\ Revert:(.*)"

    # Verify our migration file matches regex
    if [[ ! "$contents" =~ $revert_regex ]]; then
        echo "Migration file is misformatted"
        return $Ash__FALSE
    fi

    # Get Revert SQL
    revert="${BASH_REMATCH[1]}"
    if [[ "$revert" = "" ]]; then
         echo "Can't run an empty revert"
         return $Ash__FALSE
    fi

    # Run Revert
    local result=""
    result="$(Sql__execute "$revert")"
    if [[ $? -ne $Ash__TRUE ]]; then
        echo "$result"
        return $Ash__FALSE
    fi

    # Update `active` field for query just ran
    local sql="$(Migrate_set_active_query "$1" "$Sql__FALSE")"
    result="$(Sql__execute "$sql")"
    if [[ $? -ne $Ash__TRUE ]]; then
        echo "$result"
        return $Ash__FALSE
    fi
}


#################################################
# Rolls back migrations.
#
# @param $1: The maximum number of migrations to
#   roll back.  If $1 is not specified, all
#   migrations are rolled back.
#################################################
Migrate_rollback() {
    # Get maximum number of rollbacks
    local max_rollbacks="-1"
    if [[ -n $1 ]]; then
        max_rollbacks="$1"
    fi

    # Loading all migrations
    local result=""
    result="$(Sql__execute "$(Migrate_select_all_migrations_desc_query)")"
    if [[ $? -eq $Ash__FALSE ]]; then
        Logger__error "Failed to load migrations"
        Logger__error "$result"
        return $Ash__FALSE
    fi

    # Go through all migrations and run the revert
    local count=0
    while read -r record; do
        while IFS=$'\t' read id name active created_at; do
            # If we have run all our count will allow, exit
            if [[ "$max_rollbacks" -ne "-1" ]] && [[ "$count" -ge "$max_rollbacks" ]]; then
                return $Ash__TRUE
            fi
            # Rollback
            if [[ "$active" = $Sql__TRUE ]]; then
                local result=""
                result="$(Migrate_run_revert "$id" "$name" "$created_at")"
                if [[ $? -ne $Ash__TRUE ]]; then
                    Logger__error "Failed to run revert '$name'"
                    Logger__error "$result"
                    return $Ash__FALSE
                else
                    count=$((count+1))
                    Logger__success "Reverted $name"
                fi
            fi
        done <<< "$record"
    done <<< "$result"
}

#################################################
# Migrates all migrations.
#
# @param $1: The maximum number of migrations to
#   migrate
#################################################
Migrate_migrate() {
    # Get maximum number of migrations
    local max_migrations="-1"
    if [[ -n $1 ]]; then
        max_migrations="$1"
    fi

    # Loading all migrations
    local result=""
    result="$(Sql__execute "$(Migrate_select_all_migrations_asc_query)")"
    if [[ $? -eq $Ash__FALSE ]]; then
        Logger__error "Failed to load migrations"
        Logger__error "$result"
        return $Ash__FALSE
    fi

    # Go through all migrations and run them
    local count=0
    while read -r record; do
        while IFS=$'\t' read id name active created_at; do
            # If we have run all our count will allow, exit
            if [[ "$max_migrations" -ne "-1" ]] && [[ "$count" -ge "$max_migrations" ]]; then
                return $Ash__TRUE
            fi

            # Migrate
            if [[ "$active" = $Sql__FALSE ]]; then
                local result=""
                result="$(Migrate_run_migration "$id" "$name" "$created_at")"
                if [[ $? -ne $Ash__TRUE ]]; then
                    Logger__error "Failed to run migration '$name'"
                    Logger__error "$result"
                    return $Ash__FALSE
                else
                    count=$((count+1))
                    Logger__success "Migrated $name"
                fi
            fi
        done <<< "$record"
    done <<< "$result"
}
