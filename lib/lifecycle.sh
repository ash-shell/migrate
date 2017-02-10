#!/bin/bash

#################################################
# Ensures that everything is set up to prep
# to run migrations.
#
# @returns: $Ash__TRUE if everything was set up
#   properly, $Ash__FALSE if there was a problem.
#################################################
Migrate_setup(){
    # Verify that our migrations directory exists
    if [[ ! -d "$Migrate_MIGRATIONS_CURRENT_DIRECTORY" ]]; then
        Logger__error "There is no ./$MIGRATE_MIGRATIONS_DIRECTORY directory."
        return $Ash__FALSE
    fi

    # Verify we have a driver set
    if [[ "$MIGRATE_DATABASE_DRIVER" = "" ]]; then
        Logger__error 'No driver selected, must set $MIGRATE_DATABASE_DRIVER'
        return $Ash__FALSE
    fi

    # Open Driver
    Sql__open "$MIGRATE_DATABASE_DRIVER"
    if [[ $? -ne 0 ]]; then
        Sql__close
        Logger__error "Invalid driver '$MIGRATE_DATABASE_DRIVER'"
        return $Ash__FALSE
    fi

    # Import Queries
    source "$Migrate_PACKAGE_LOCATION/lib/queries/sql.sh"
    source "$Migrate_PACKAGE_LOCATION/lib/queries/$MIGRATE_DATABASE_DRIVER.sh"

    # Verify Connection
    local ping_result
    ping_result=$(Sql__ping)
    if [[ $? -ne 0 ]]; then
        Sql__close
        Logger__error "Error connecting to database:\n\n$ping_result" -e
        return $Ash__FALSE
    fi

    # Check if table exists
    $(Sql__table_exists "$MIGRATE_MIGRATIONS_TABLE")
    if [[ $? -ne 0 ]]; then
        # Create table
        create_table_result="$(Sql__execute "$(Migrate_create_migrations_table_query)")"
        if [[ $? -ne 0 ]]; then
            Logger__error "Failed to create table:\n\n$create_table_result" -e
            return $Ash__FALSE
        fi
    fi

    # Track untracked migrations
    for file in "$Migrate_MIGRATIONS_CURRENT_DIRECTORY/"*.sql
    do
        local migration_name=$(basename "$file")
        local migration_regex="([0-9]+)_(.+)\.sql"
        if [[ "$migration_name" =~ $migration_regex ]]; then
            date="${BASH_REMATCH[1]}"
            name="${BASH_REMATCH[2]}"

            Migrate_is_tracked "$name"
            if [[ $? -eq $Ash__FALSE ]]; then
                local result=""
                result=$(Migrate_create_migration "$name" "$date")
                if [[ $? -eq $Ash__TRUE ]]; then
                    Logger__success "Tracking $name"
                else
                    Logger__error "Failed to track $name"
                    Logger__error "$result"
                fi
            fi
        fi
    done
}

#################################################
# Shuts down everything.
#################################################
Migrate_shutdown(){
    Sql__close
}
