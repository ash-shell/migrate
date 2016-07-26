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
    Migrate_setup
    if [[ $? -ne $Ash__TRUE ]]; then
        return $Ash__FALSE
    fi

    Migrate_shutdown
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
    Logger__log "migrate:sync"
}

#################################################
#################################################
Migrate__callable_rollback(){
    Logger__log "migrate:rollback"
}

#################################################
#################################################
Migrate__callable_reset(){
    Logger__log "migrate:reset"
}

#################################################
#################################################
Migrate__callable_refresh(){
    Logger__log "migrate:refresh"
}

#################################################
#################################################
Migrate__callable_map(){
    Logger__log "migrate:map"
}

#################################################
#################################################
Migrate__callable_step(){
    Logger__log "migrate:step"
}
