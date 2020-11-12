# airflow-jupyter-docker-compose
Orchestration of data science and earth observation models in Apache Airflow, scale-up with Celery Executor, experiment with jupyter notebook using a docker containers composition. Based on `https://github.com/puckel/docker-airflow` works.

## Commands to deploy and manage the stack behind an HTTPS automated proxy: 
* Ensure that appropriate DNS record for `airflow` base URL is created and resolve well. 
* Ensure that your automated nginx-proxy (e.g. ) is up and running.
* Create the `airflow-proxy` network -> `sudo docker network create airflow-proxy`
* Attach the new network to the existing `nginx-proxy` container to ensure proper proxy operations -> `sudo docker network connect airflow-proxy <nginx-proxy container name>`
* Bring up the whole stack ->  `sudo docker-compose up -d --build`

## Stack management
* Stop containers : `sudo docker-compose down`
* View Container : `sudo docker ps`
* Go inside a container : `sudo docker-compose exec -it <service-id> bash`
* See logs of a container: `sudo docker logs <service-id>`
* Monitor containers : `sudo docker stats`

## Available URL list
* `airflow.<your-awesome-domain.ltd>` -> airflow web UI
* `airflow.<your-awesome-domain.ltd>/flower` -> Flower, celery workers Web UI
* `airflow.<your-awesome-domain.ltd>/pgadmin` -> pgadmin4
* `airflow.<your-awesome-domain.ltd>/jupyter` -> jupyter notebook (default password : notebook)

## Deployed librairies 
* siphon (https://github.com/Unidata/siphon)
* cartopy (https://scitools.org.uk/cartopy/docs/latest/)
* netcdf4 (http://unidata.github.io/netcdf4-python/netCDF4/index.html)
* xarray (http://xarray.pydata.org/en/stable/)
* ffmpeg (for videos)
* dask (https://dask.org/)
* scikit-learn (https://scikit-learn.org/stable/)
* seaborn (http://seaborn.pydata.org/)
* magics (https://github.com/ecmwf/magics-python)
* iris (https://scitools.org.uk/iris/docs/latest/)
* metpy (https://unidata.github.io/MetPy/latest/index.html)
