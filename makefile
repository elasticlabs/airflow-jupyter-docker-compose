# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# Variables initialization from .env file
DC_PROJECT?=$(shell cat .env | grep COMPOSE_PROJECT_NAME | sed 's/^*=//')
AIRFLOW_URL?=$(shell cat .env | grep VIRTUAL_HOST | sed 's/.*=//')
CURRENT_DIR?= $(shell pwd)
AIRFLOW_VOLUMES?=$(shell docker-compose config --volumes)

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
	@bash ./.utils/message.sh info "[INFO] Building the Airflow stack"
	@bash ./.utils/message.sh info "[INFO] The following URL is detected : $(AIRFLOW_URL). It should be reachable for proper operation"
	nslookup $(AIRFLOW_URL) && echo "        -> nslookup OK!"
	# Set server_name in reverse proxy
	sed -i "s/changeme/$(AIRFLOW_URL)/" .proxy/airflow-stack.conf
	# Build the stack
	docker-compose -f docker-compose.yml build
	# Run the stack
	docker-compose -f docker-compose.yml up -d
	@make urls

.PHONY: down
down:
	@bash ./.utils/message.sh info "[INFO] Bringing done the Airflow stack"
	docker-compose -f docker-compose.yml down --remove-orphans
	@bash ./.utils/message.sh info "[INFO] Done. See (sudo make cleanup) for containers, images, and static volumes cleanup"

.PHONY: hard-cleanup
hard-cleanup: save-volumes-links
	@bash ./.utils/message.sh info "[INFO] Bringing done the Airflow stack"
	docker-compose -f docker-compose.yml down --remove-orphans
	# 2nd : clean up all containers & images, without deleting static volumes
	@bash ./.utils/message.sh info "[INFO] Cleaning up containers & images"
	docker system prune -a
	# Delete all hosted persistent data available in volumes
	@bash ./.utils/message.sh info "[INFO] Cleaning up static volumes"
	docker volume rm -f $(DC_PROJECT)pgadmin_data
	docker volume rm -f $(DC_PROJECT)airflow_dags
	docker volume rm -f $(DC_PROJECT)airflow_scripts
	docker volume rm -f $(DC_PROJECT)jupyter_notebooks
	# Remove all dangling docker volumes
	@bash ./.utils/message.sh info "[INFO] Remove all dangling docker volumes"
	docker volume rm $(shell docker volume ls -qf dangling=true)

.PHONY: save-volumes-links
save-volumes-links:
	@bash ./.utils/volumes_links.sh save $(CURRENT_DIR) $(DC_PROJECT) $(AIRFLOW_VOLUMES)

.PHONY: build-volumes-links
build-volumes-links:
	@bash ./.utils/volumes_links.sh build $(CURRENT_DIR) $(DC_PROJECT) $(AIRFLOW_VOLUMES)

.PHONY: urls
urls:
	@bash ./.utils/message.sh headline "[INFO] You may now access your project at the following URLs:"
	@bash ./.utils/message.sh link "JupyterLab:  https://${APP_BASEURL}/"
	@bash ./.utils/message.sh link "Flower GUI:      https://${APP_BASEURL}/flower/"
	@bash ./.utils/message.sh link "PGAdmin:         https://${APP_BASEURL}/pgadmin/"
	@bash ./.utils/message.sh link "Airflow WebGUI:      https://${APP_BASEURL}/airflow/"
	@bash ./.utils/message.sh link "Geoserver WebGUI:      https://${APP_BASEURL}/geoserver/"
	@echo ""

.PHONY: pull
pull: 
	docker-compose -f docker-compose.yml pull

.PHONY: update
update: pull up wait
	docker system prune -a

.PHONY: wait
wait: 
	sleep 5