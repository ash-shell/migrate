# Migrate

Migrate is an [Ash](https://github.com/ash-shell/ash) module that allows users to manage database migrations directly with SQL.

## Why should you care?

As someone who has worked with many programming languages and frameworks, I've been introduced to a bunch of different migration tools. All of them that I've run into force you into using an ORM that's written in a specific programming language. ORMs tend to do a good job when the queries are simple, but as the queries get more complex the ORM code is very frequently more complicated than the actual SQL query itself.  In the process of distancing myself away from ORMs, I discovered that there is not any good migration CLI tools that allow you to work with SQL directly.

This Ash module allows you to do exactly that: write SQL for your queries.

## What will my migrations look like?

Your migration files will simply look something like this:

```sql
-- Migrate:
CREATE TABLE people(
    id integer,
    name varchar(20)
);

-- Revert:
DROP TABLE people;
```

## Getting Started

You're going to have to install [Ash](https://github.com/ash-shell/ash) to use this module.

After you have Ash installed, run either one of these two commands depending on your git clone preference:

```sh
ash apm:install https://github.com/ash-shell/migrate.git --global
ash apm:install git@github.com:ash-shell/migrate.git --global
```

You're also going to need to have Ash's [SQL](https://github.com/ash-shell/sql) module installed as this module is dependent on it.

> You'll have to install SQL manually for now. In the future Ash will support nested dependencies.

## Environment Variables

Before jumping into using this library, you're going to have to set some environment variables so Migrate knows how to connect to your database.

I would recommend creating a .env file and sourcing it to the terminal that you'll be running your migrations from.

### Database Driver

To start off, you're going to need to specify the database driver:

```sh
export MIGRATE_DATABASE_DRIVER='mysql|postgres'
```

### Database Specific

You'll need to then set the environment variables for the specific database driver you've picked that the [SQL](https://github.com/ash-shell/sql) module expects.

To avoid repeating myself check out [SQLs environment variable section](https://github.com/ash-shell/sql#environment-variables) to see what you'll need to set.

## Usage

To get started running migrations for a project you'll need to create a folder named `ash_migrations` in it.

All of the following commands should be called in the directory that holds this folder.

> You can override what this folder is named by setting `MIGRATE_MIGRATIONS_DIRECTORY` in your environment variables.

### Creating Migrations

To create a new migration, run the following command:

```sh
ash migrate:make $migration_name
```

Where `$migration_name` is a name that describes your migration.

### Running All Outstanding Migrations

To run all outstanding migrations, run the following command:

```
ash migrate
```

### Check Status of Migrations

To check the status of migrations, run the following command:

```
ash migrate:map
```

This will output something that looks like this:

```
> create_people_table
> create_animals_table
> create_dogs_table
  create_foo_table
  create_baz_table
```

Migrations with `>` in front of them have been run.

### Rollback All Migrations

To roll back all migrations, run the following command:

```
ash migrate:rollback
```

### Refresh All Migrations

Sometimes you need to roll back all of your migrations and then run them again.  This library has a single command to accomplish this:

```
ash migrate:refresh
```

### Step Through Migrations

There's a case where you wouldn't want to run all of you migrations, or revert all of your migrations at once.

The step command offers the ability to go through as many migrations/reverts as you want.

The command is formated like this:

```sh
ash migrate:step [+-][[:digit:]]+
```

For example, to run the next two migrations you would run:

```sh
ash migrate:step +2
```

For example, to revert the last three migrations you would run:

```
ash migrate:step -3
```

## License

[MIT](./LICENSE.md)
