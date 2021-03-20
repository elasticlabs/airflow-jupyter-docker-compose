#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$AIRFLOW_USER"
export PGDB="$AIRFLOW_DB"
export PGDB_PASSWD="$AIRFLOW_PASSWORD"

# 
# Create airflow database : 
# See https://airflow.apache.org/docs/apache-airflow/stable/howto/set-up-database.html#setting-up-a-postgresql-database for more information
"${psql[@]}" <<- 'EOSQL'
    DO
    $do$
    BEGIN
    IF NOT EXISTS (
        SELECT
        FROM pg_database 
        WHERE datname = '$PGDB') THEN
        
        CREATE DATABASE '$PGDB');
    END IF;
    END
    $do$;
EOSQL

#
# Create and grant access rights to user $PGUSER
"${psql[@]}" --dbname="$PGDB" <<-'EOSQL'
		DO
        $do$
        BEGIN
        IF NOT EXISTS (
            SELECT                       -- SELECT list can stay empty for this
            FROM   pg_catalog.pg_roles
            WHERE  rolname = '$PGUSER') THEN

            CREATE ROLE $PGUSER LOGIN PASSWORD '$PGDB_PASSWORD';
            GRANT ALL PRIVILEGES ON DATABASE '$PGDB' TO '$PGUSER';
            ALTER ROLE '$PGUSER' SET search_path = airflow, geoserver;
        END IF;
        END
        $do$;
EOSQL