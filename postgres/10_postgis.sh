#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$GEOSERVER_USER"
export PGDB="$GEOSERVER_DB"
export PGDB_PASSWD="$GEOSERVER_PASSWORD"

# Create the 'postgis_template' template db
# TODO : proper tables rights management : https://docs.bitnami.com/aws/infrastructure/postgresql/configuration/create-postgis-template/
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE postgis_template IS_TEMPLATE true;
EOSQL

# Load PostGIS into both template_database and $GEOSERVER_DB
for DB in postgis_template "$GEOSERVER_DB"; do
	echo "Loading PostGIS and PGRouting extensions into $DB"
	"${psql[@]}" --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
        CREATE EXTENSION IF NOT EXISTS pgrouting;
EOSQL
done

# Create and grant access rights to user $GEOSERVER_DB
"${psql[@]}" --dbname="$GEOSERVER_DB" <<-'EOSQL'
		DO
        $do$
        BEGIN
        IF NOT EXISTS (
            SELECT                       -- SELECT list can stay empty for this
            FROM   pg_catalog.pg_roles
            WHERE  rolname = '$GEOSERVER_USER') THEN

            CREATE ROLE $GEOSERVER_USER LOGIN PASSWORD '$GEOSERVER_PASSWORD';
            GRANT ALL PRIVILEGES ON DATABASE $GEOSERVER_DB TO $GEOSERVER_USER;
        END IF;
        END
        $do$;
EOSQL