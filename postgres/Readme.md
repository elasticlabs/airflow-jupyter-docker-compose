A simple container with postGIS, based on `https://github.com/postgis/docker-postgis`
 proxy.

This image ensures that the default database created by the parent `postgres` image will have the following extensions installed:
* `postgis`
* `postgis_topology`
* `pgrouting`
* `fuzzystrmatch`
* `postgis_tiger_geocoder`

## Environments and default databases
| Database | Admin User | Admin User (default) password |
|---|---|---|
| `postgres` | As `POSTGRES_USER` the default is **postgres** | As `POSTGRES_PASSWORD` the default is **changeme** |
| `airflow` | As defined with `AIRFLOW_USER` the default is **airflow** | As defined with `AIRFLOW_PASSWORD`  the default is **changeme** |
| `geoserver` | As defined with `GEOSERVER_USER` the default is **geoserver** | As defined with `GEOSERVER_PASSWORD` the default is **changeme** |

## Access to postgres: 
* `localhost:5432`
* **Username:** postgres (as the default)
* **Password:** changeme (as the default)

## TODO : dummy project starting from PGAdmin4 exported JSON Servers list