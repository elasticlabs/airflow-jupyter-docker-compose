FROM postgres:13
LABEL maintainer="Elasticlabs <contact@elasticlabs.co>"

ENV \
    # PostGIS basics
    PG_MAJOR=13 \
    POSTGIS_MAJOR=3

RUN apt-get update \
      && apt-cache showpkg postgresql-${PG_MAJOR}-postgis-${POSTGIS_MAJOR} \
      && apt-get install -y --no-install-recommends \
           postgresql-${PG_MAJOR}-postgis-${POSTGIS_MAJOR} \
           postgresql-${PG_MAJOR}-postgis-${POSTGIS_MAJOR}-scripts \
           # From official postgis Dockerfile, add complementary packages
           postgresql-${PG_MAJOR}-pgrouting \
           netcat \
           postgresql-${PG_MAJOR}-ogr-fdw \
           postgresql-plpython3-${PG_MAJOR} \
           postgresql-server-dev-${PG_MAJOR} \
           postgresql-${PG_MAJOR}-cron

# Cleanup resources
RUN apt-get -y --purge autoremove  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Placing initialization script into appropriate directory
# -> https://hub.docker.com/_/postgres (Initialzation scripts)
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./09_postgres-airflow.sh /docker-entrypoint-initdb.d/09_postgres-airflow.sh
COPY ./10_geoserver.sh /docker-entrypoint-initdb.d/10_geoserver.sh
COPY ./update-postgis.sh /usr/local/bin/update-postgis.sh
RUN chmod +x /usr/local/bin/update-postgis.sh