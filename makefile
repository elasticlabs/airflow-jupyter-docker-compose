# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# Variables initialization from .env file
DC_PROJECT?=$(shell cat .env | sed 's/^*=//')
AIRFLOW_URL?=$(shell grep LETSENCRYPT_HOST docker-compose.yml | sed 's/\=/ /' | awk '{print $3}')


# Every command is a PHONY, to avoid file naming confliction -> strengh comes from good habits!
.PHONY: help
help:
	@echo "=============================================================================================="
	@echo "        Orchestration of data science and earth observation models in Apache Airflow "
	@echo "             https://github.com/elasticlabs/airflow-jupyter-docker-compose"
	@echo " "
	@echo "Hints for developers:"
	@echo "  make up             # With working HTTPS proxy, bring up the Airflow stack"
	@echo "  make down           # Brings the Airflow stack down. "
	@echo "  make update         # Update the whole stack"
	@echo "  make hard-cleanup   # Complete hard cleanup of images, containers, networks, volumes & data"
	@echo "=============================================================================================="

.PHONY: up
up:
	@echo "[INFO] Building the Airflow stack"
	@echo "[INFO] The following URL is detected : $(AIRFLOW_URL). It should be reachable for proper operation"
	nslookup $(AIRFLOW_URL) && echo "        -> nslookup OK!"
	docker-compose -f docker-compose.yml up -d --build

.PHONY: down
down:
    @echo "[INFO] Bringing done the Airflow stack"
	docker-compose -f docker-compose.yml down --remove-orphans
	@echo "[INFO] Done. See (sudo make cleanup) for containers, images, and static volumes cleanup"

.PHONY: cleanup
cleanup:
    @echo "[INFO] Bringing done the Airflow stack"
	docker-compose -f docker-compose.yml down --remove-orphans
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
    docker-compose -f docker-compose.yml pull    

.PHONY: update
update: pull up wait
	docker image prune

.PHONY: wait
wait: 
	sleep 5