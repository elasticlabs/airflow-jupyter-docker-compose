#!/bin/bash
set -e

#
# Create the "airflow" database and grant all access to "postgres" user 
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE $AIRFLOW_DB;
    GRANT ALL PRIVILEGES ON DATABASE $AIRFLOW_DB TO $POSTGRES_USER;
EOSQL

#
# Create role "airflow" if needed and grant it all accesses to "airflow" database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$AIRFLOW_DB" <<-EOSQL
    DO
        $do$
        BEGIN
        IF NOT EXISTS (
            SELECT                       -- SELECT list can stay empty for this
            FROM   pg_catalog.pg_roles
            WHERE  rolname = '$AIRFLOW_USER') THEN

            CREATE ROLE $AIRFLOW_USER LOGIN PASSWORD '$AIRFLOW_PASSWORD';
            GRANT ALL PRIVILEGES ON DATABASE '$AIRFLOW_DB' TO '$AIRFLOW_USER';
            -- ALTER ROLE '$AIRFLOW_USER' SET search_path = airflow, geoserver, postgres;
        END IF;
        END
        $do$;
EOSQL