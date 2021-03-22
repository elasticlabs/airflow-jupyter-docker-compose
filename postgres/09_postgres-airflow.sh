#!/bin/bash
set -e

#
# Create the "airflow" database and grant all access to "postgres" user 
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE $AIRFLOW_USER LOGIN PASSWORD '$AIRFLOW_PASSWORD';
    CREATE DATABASE $AIRFLOW_DB;
    GRANT ALL PRIVILEGES ON DATABASE $AIRFLOW_DB TO $AIRFLOW_USER;
EOSQL