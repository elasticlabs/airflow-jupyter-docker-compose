Dockerized PGAdmin4, built on top of [PGAdmin official image](https://hub.docker.com/r/dpage/pgadmin4/)

## Features & tweaks
* Automates configuration of default user
* Automates SDI server configuration file

## Configuration 
You can customize this deployemnt using the following variables in the `.env` file :
| Variables | Details |
|---|---|
| `PGADMIN_DEFAULT_EMAIL` | Customize user login email address |
| `PGADMIN_DEFAULT_PASSWORD` | Set to `SuperSecret` by default; Modify it before deployment |