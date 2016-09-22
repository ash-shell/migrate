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

You'll need to then set the environment variables for the specific database driver you've picked that the SQL module expects.

To avoid repeating myself check out [SQLs environment variable section](https://github.com/ash-shell/sql#environment-variables) to see what you'll need to set.

## Usage
