#!/bin/sh

set -e

# Create the 'postgis_template' template db
# TODO : proper tables rights management : https://docs.bitnami.com/aws/infrastructure/postgresql/configuration/create-postgis-template/
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE postgis_template IS_TEMPLATE true;
    CREATE ROLE $GEOSERVER_USER LOGIN PASSWORD '$GEOSERVER_PASSWORD';
    CREATE DATABASE $GEOSERVER_DB;
    GRANT ALL PRIVILEGES ON DATABASE $GEOSERVER_DB TO $GEOSERVER_USER;
EOSQL

# Load PostGIS into both template_database and $GEOSERVER_DB
for DB in postgis_template "$GEOSERVER_DB"; do
	echo "Loading PostGIS and PGRouting extensions into $DB"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
        CREATE EXTENSION IF NOT EXISTS pgrouting;
	EOSQL
done