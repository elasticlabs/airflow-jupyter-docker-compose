A simple container with postGIS, based on `https://github.com/postgis/docker-postgis`
 proxy.

This image ensures that the default database created by the parent `postgres` image will have the following extensions installed:
* `postgis`
* `postgis_topology`
* `pgrouting`
* `fuzzystrmatch`
* `postgis_tiger_geocoder`

Here are some characteristics : 
* Connections are restricted to the docker subnet
* A default database `geoserver` is created during the building process, with username `geoserver` with all access granted
* Enable multiple extensions in the database when setting it up : postgis, pgrouting, etc.
* Gdal drivers automatically registered for pg raster
* Support for out-of-db rasters

## Usage :
| Option | Details |
|---|---|
| Inside the SDI | Find `pgadmin4` administration interface at `https://<your-awesome-domain.ltd/pgadmin>`, all should be already configured |
| Commandline #1 | Use `docker-compose exec postgis /bin/bash` then `psql -U geoserver` |
| Commendline #2 | The PostgreSQL utilities `pg_dump`, `pg_dumpall`, `pg_restore` and `psql` are included in the `pgadmin` container (https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html) |

**Notes** 
* This container is meant to be integrated into a complete FOSS SDI stack :
* For now, it doens't include clustering and specific, so some work may be required when driving to production use
* All HTTPS reverse proxy work is covered by the `nginx-enrypoint` SDI reverse