# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# For cleanup, get Compose project name from .env file
DC_PROJECT?=$(shell cat .env | sed 's/^*=//')

# Every command is a PHONY, to avoid file naming confliction -> strengh comes from good habits!
.PHONY: help
help:
	@echo "=============================================================================="
	@echo " Orchestration of data science and earth observation models in Apache Airflow "
	@echo "  https://github.com/elasticlabs/airflow-jupyter-docker-compose"
	@echo " "
	@echo "Hints for developers:"
	@echo "  make up            # With working HTTPS proxy, bring up the Airflow stack"
	@echo "  make down          # Brings the Airflow stack down. "
	@echo "  make logs          # Follows whole Airflow stack logs (Airflow, PGAdmin, Flower, Jyputer notebook)"
	@echo "  make cleanup       # Complete hard cleanup of images, containers, networks, volumes & data"
	@echo "  make update        # Update the whole stack"
	@echo "=============================================================================="

.PHONY: up
up:
	@echo "[INFO] Building the Airflow stack"
	AIRFLOW_URL?=$(shell grep LETSENCRYPT_HOST docker-compose.nginx-proxy.yml | sed 's/\=/ /' | awk '{print $3}')
	@echo "[INFO] The following URL is detected : $(AIRFLOW_URL). It should be reachable for proper operation"
	#docker network create airflow-proxy
	#docker network connect airflow-proxy <nginx-proxy container name>
	#TODO : automatic network test & connection
	docker-compose -f docker-compose.nginx-proxy.yml up -d --build

.PHONY: logs
logs:
    @echo "[INFO] Following latest logs"
	docker-compose -f docker-compose.nginx-proxy.yml logs --follow

.PHONY: down
down:
    @echo "[INFO] Bringing done the HTTPS automated proxy"
	docker-compose -f docker-compose.nginx-proxy.yml down --remove-orphans
	@echo "[INFO] Done. See (sudo make cleanup) for containers, images, and static volumes cleanup"

.PHONY: cleanup
cleanup:
    @echo "[INFO] Bringing done the HTTPS automated proxy"
	docker-compose -f docker-compose.nginx-proxy.yml down --remove-orphans
	# 2nd : clean up all containers & images, without deleting static volumes
    @echo "[INFO] Cleaning up containers & images"
	docker rm $(docker ps -a -q)
	docker rmi $(docker images -q)
	docker system prune -a
    # Delete all hosted persistent data available in volumes
	@echo "[INFO] Cleaning up static volumes"
    docker volume rm -f $(DC_PROJECT)pgadmin_data
    docker volume rm -f $(DC_PROJECT)airflow_dags
    docker volume rm -f $(DC_PROJECT)airflow_scripts
    docker volume rm -f $(DC_PROJECT)jupyter_notebooks
	# Remove all dangling docker volumes
	@echo "[INFO] Remove all dangling docker volumes"
	docker volume rm $(shell docker volume ls -qf dangling=true)

.PHONY pull
pull: 
    docker-compose -f docker-compose.nginx-proxy.yml pull    

.PHONY: update
update: pull up wait
	docker image prune

.PHONY: wait
wait: 
	sleep 5