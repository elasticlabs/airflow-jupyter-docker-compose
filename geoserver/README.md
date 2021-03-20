Dockerized GeoServer, built on top of [Docker's official tomcat image](https://hub.docker.com/_/tomcat/), with inspiration from [Kartoza](https://github.com/kartoza/docker-geoserver)

## Features
* Separate GEOSERVER_DATA_DIR location (on /var/local/geoserver).
* Extensions automated deploymmnt
* [CORS ready](http://enable-cors.org/server_tomcat.html).
* Running tomcat process as non-root user.
* Taken care of [JVM Options](http://docs.geoserver.org/latest/en/user/production/container.html).
* Automatic installation of [Microsoft Core Fonts](http://www.microsoft.com/typography/fonts/web.aspx) for better labelling compatibility.

## Extensions deployment 
Extensions automated deployemnt through the following `Dockerfile` variables : `STABLE_EXTENSIONS` and `COMMUNITY_EXTENSIONS`.
You can customise the 2 lists using following references : 
| Resource | Details |
|---|---|
| Files | See `stable_plugins.txt` and `community_plugins.txt` build files for valid entries into the list. |
| Geoserver extensions page | [Global information on extensions](http://geoserver.org/release/stable/) |