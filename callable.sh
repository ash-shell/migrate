#!/bin/bash

Ash__import "github.com/ash-shell/sql"

# Configurable
MIGRATE_MIGRATIONS_TABLE="ash_migrations"
MIGRATE_MIGRATIONS_DIRECTORY="ash_migrations"
MIGRATE_DATABASE_DRIVER="$Sql__DRIVER_POSTGRES"

# Global Const
Migrate_PACKAGE_LOCATION="$(Ash__find_module_directory "github.com/ash-shell/migrate")"
Migrate_MIGRATIONS_CURRENT_DIRECTORY="$Ash__CALL_DIRECTORY/$MIGRATE_MIGRATIONS_DIRECTORY"
Migrate_MIGRATION_TEMPLATE="$Migrate_PACKAGE_LOCATION/extra/migration_template.sql"

#################################################
#################################################
Migrate__callable_help(){
    more "$Ash__ACTIVE_MODULE_DIRECTORY/HELP.txt"
}

#################################################
#################################################
Migrate__callable_main(){
    # Setup
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    # Migrate
    local result=$Ash__TRUE
    Migrate_migrate_all
    if [[ $? -ne $Ash__TRUE ]]; then
        result=$Ash__FALSE
    fi

    # Shutdown
    Migrate_shutdown
    return "$result"
}

#################################################
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
        return $Ash__FALSE
    fi

    # Shutdown
    Migrate_shutdown
}

#################################################
#################################################
Migrate__callable_sync(){
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    Migrate_shutdown
}

#################################################
#################################################
Migrate__callable_rollback(){
    # Setup
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    # Rollback
    local result=$Ash__TRUE
    Migrate_rollback_all
    if [[ $? -ne $Ash__TRUE ]]; then
        result=$Ash__FALSE
    fi

    # Shutdown
    Migrate_shutdown
    return "$result"
}

#################################################
#################################################
Migrate__callable_refresh(){
    # Setup
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    # Rollback
    Migrate_rollback_all
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
        Migrate_shutdown
    fi

    Logger__warning "------------------------"

    # Migrate
    Migrate_migrate_all
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
        Migrate_shutdown
    fi

    # Shutdown
    Migrate_shutdown
}

#################################################
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
#################################################
Migrate__callable_step(){
    Logger__log "migrate:step"
}
