#!/bin/bash

Ash__import "github.com/ash-shell/sql"

# Set defaults if none set
if [[ "$MIGRATE_MIGRATIONS_TABLE" = "" ]]; then
    MIGRATE_MIGRATIONS_TABLE="ash_migrations"
fi
if [[ "$MIGRATE_MIGRATIONS_DIRECTORY" = "" ]]; then
    MIGRATE_MIGRATIONS_DIRECTORY="ash_migrations"
fi
if [[ "$MIGRATE_DATABASE_DRIVER" = "" ]]; then
    MIGRATE_DATABASE_DRIVER="$Sql__DRIVER_POSTGRES"
fi

# Global Const
Migrate_PACKAGE_LOCATION="$(Ash__find_module_directory "github.com/ash-shell/migrate")"
Migrate_MIGRATIONS_CURRENT_DIRECTORY="$Ash__CALL_DIRECTORY/$MIGRATE_MIGRATIONS_DIRECTORY"
Migrate_MIGRATION_TEMPLATE="$Migrate_PACKAGE_LOCATION/extra/migration_template.sql"

#################################################
# Runs more on the contents of the HELP.txt file
# which provides usage information for this module.
#################################################
Migrate__callable_help(){
    more "$Ash__ACTIVE_MODULE_DIRECTORY/HELP.txt"
}

#################################################
# Runs all outstanding migrations.
#################################################
Migrate__callable_main(){
    # Setup
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    # Migrate
    Migrate_migrate
    if [[ $? -ne $Ash__TRUE ]]; then
        Migrate_shutdown
        return $Ash__FALSE
    fi

    # Shutdown
    Migrate_shutdown
}

#################################################
# Creates a new migration, which creates a new
# file in the "$Migrate_MIGRATIONS_CURRENT_DIRECTORY"
# directory for the user to fill out with their
# migration.
#################################################
Migrate__callable_make(){
    # Setup
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    # Get name + timestamp
    local name="$1"
    local timestamp="$(date +%s)"

    # Add migration to DB
    local result=""
    result=$(Migrate_create_migration "$name" "$timestamp")
    if [[ $? -eq $Ash__TRUE ]]; then
        # Create migration file
        local migration_file="$Migrate_MIGRATIONS_CURRENT_DIRECTORY"/"$timestamp"_"$name".sql
        cp "$Migrate_MIGRATION_TEMPLATE" "$migration_file"
        Logger__success "Created migration $name in ./$MIGRATE_MIGRATIONS_DIRECTORY"
    else
        Logger__error "Failed to create migration."
        Logger__error "$result"
        Migrate_shutdown
        return $Ash__FALSE
    fi

    # Shutdown
    Migrate_shutdown
}

#################################################
# Rolls back all of the migrations that have been
# run in the database.
#################################################
Migrate__callable_rollback(){
    # Setup
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    # Rollback
    Migrate_rollback
    if [[ $? -ne $Ash__TRUE ]]; then
        Migrate_shutdown
        return $Ash__FALSE
    fi

    # Shutdown
    Migrate_shutdown
}

#################################################
# Rolls back all of the migrations that have been
# run in the database, then runs all of the
# migrations in the database.
#
# The same end result would occur if you run this
# command vs running `rollback` followed by a
# `migrate`.
#################################################
Migrate__callable_refresh(){
    # Setup
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    # Rollback
    Migrate_rollback
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
        Migrate_shutdown
    fi

    Logger__warning "------------------------"

    # Migrate
    Migrate_migrate
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
        Migrate_shutdown
    fi

    # Shutdown
    Migrate_shutdown
}

#################################################
# Displays the current state of the migrations.
#################################################
Migrate__callable_map(){
    # Setup
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    # Loading all migrations
    local result=""
    result="$(Sql__execute "$(Migrate_select_all_migrations_asc_query)")"
    if [[ $? -eq $Ash__FALSE ]]; then
        Logger__error "Failed to load migrations"
        Logger__error "$result"
        Migrate_shutdown
        return $Ash__FALSE
    fi

    # Go through all migrations and log them
    Logger__disable_prefix
    while read -r record; do
        while IFS=$'\t' read id name active created_at; do
            if [[ "$active" = $Sql__TRUE ]]; then
                Logger__success " > $name"
            else
                Logger__log "   $name"
            fi done <<< "$record"
    done <<< "$result"
    Logger__enable_prefix

    # Shutdown
    Migrate_shutdown
}

#################################################
# Allows the user to step through their migrations.
#
# @param $1: This defines the number and direction
#   of steps.
#
#   To migrate, this parameter should be +X, where
#   X is the number of migrations to run.
#
#   To revert, this parameter should be -Y, where
#   Y is the number of migrations to revert.
#################################################
Migrate__callable_step(){
    # Setup
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    # Check if we have a step param
    if [[ -z "$1" ]]; then
        Logger__error "Step requires a parameter"
        Migrate_shutdown
        return $Ash__FALSE
    fi

    # Verify proper format
    if [[ ! "$1" =~ [+-][[:digit:]]+$ ]]; then
        Logger__error "Invalid parameter.  Step parameter must be in this format: [+-][[:digit:]]+$"
        Migrate_shutdown
        return $Ash__FALSE
    fi

    # Split Action + Number
    local action=${1:0:1}
    local number=${1:1:${#1}-1}

    # Handle migrate
    if [[ "$action" = "+" ]]; then
        Migrate_migrate "$number"
        if [[ $? -ne $Ash__TRUE ]]; then
            Migrate_shutdown
            return $Ash__FALSE
        fi
    # Handle revert
    elif [[ "$action" = "-" ]]; then
        Migrate_rollback "$number"
        if [[ $? -ne $Ash__TRUE ]]; then
            Migrate_shutdown
            return $Ash__FALSE
        fi
    fi

    # Shutdown
    Migrate_shutdown
}
