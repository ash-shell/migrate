#!/bin/bash

Ash__import "github.com/ash-shell/sql"

# Configurable
MIGRATE_MIGRATIONS_TABLE="ash_migrations"
MIGRATE_MIGRATIONS_DIRECTORY="ash_migrations"
MIGRATE_DATABASE_DRIVER="$Sql__DRIVER_POSTGRES"

# Global Const
Migrate_PACKAGE_LOCATION="$(Ash__find_module_directory "github.com/ash-shell/migrate")"
Migrate_MIGRATIONS_CURRENT_DIRECTORY="$Ash__CALL_DIRECTORY/$MIGRATE_MIGRATIONS_DIRECTORY"

#################################################
#################################################
Migrate__callable_help(){
    more "$Ash__ACTIVE_MODULE_DIRECTORY/HELP.txt"
}

#################################################
#################################################
Migrate__callable_main(){
    Migrate_setup
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    Migrate_shutdown
}

#################################################
#################################################
Migrate__callable_make(){
    Logger__log "migrate:make"
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
