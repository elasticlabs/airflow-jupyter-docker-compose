# airflow-jupyter-docker-compose
Orchestration of data science and earth observation models in Apache Airflow, scale-up with Celery Executor, experiment with jupyter notebook using a docker containers composition. Based on `https://github.com/puckel/docker-airflow` works.

This software stack comes with 2 compose file versions : 
* Standalone version : `docker-compose.standalone.yml`
* Deployment behind an automated HTTPS proxy (see `https://github.com/nginx-proxy/nginx-proxy` for more information) : `docker-compose.nginx-proxy.yml`

## Commands to deploy and manage the stack 
* Bring up the stack : `sudo docker-compose -f docker-compose.standalone.yml up -d --build`
* Bring up the stack with an HTTPS automated proxy: `sudo docker-compose -f docker-compose.nginx-proxy.yml up -d --build`

## Stack management
* Stop containers : `docker-compose down`
* View Container : `docker ps`
* Go inside a container : `sudo docker-compose -f <compose-file> exec -it <service-id> bash`
* See logs of a container: `sudo docker -f <compose-file> logs <service-id>`
* Monitor containers : `sudo docker -f <compose-file> stats`

## Deployed librairies 
* scikit-learn -> 0.23.2
* pandas -> 1.1.2
* xgboost -> 1.2.0
* iris (https://scitools.org.uk/iris/docs/latest/) -> 2.4
* metpy (https://unidata.github.io/MetPy/latest/index.html) -> 0.12.2
* metview (https://github.com/ecmwf/metview-python) -> 1.5.1
* climetlab (https://climetlab.readthedocs.io/en/latest/) -> 0.0.98

TODO : Add `Jupyter Notebook weather forecasting librairies` 