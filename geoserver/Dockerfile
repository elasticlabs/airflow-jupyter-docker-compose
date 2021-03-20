FROM tomcat:9-jdk11
LABEL maintainer="Elastic Labs <contact@elasticlabs.co>"

ENV \
    # Geoserver installation basics
    GEOSERVER_VERSION=2.18.0 \
    GEOSERVER_DATA_DIR=/var/local/geoserver \
    GEOSERVER_ADMIN_USER=admin \
    GEOSERVER_ADMIN_PASSWORD=myawesomegeoserver \
    # https://docs.geoserver.org/stable/en/user/production/container.html#optimize-your-jvm
    INITIAL_MEMORY=1G \
    MAXIMUM_MEMORY=2G

# -> GDAL Native libes
# Ativate if specific files support is needed
# https://github.com/geosolutions-it/imageio-ext/wiki/GDAL-framework-and-plugins
ARG GDAL_NATIVE=false

# Geoserver WAR location 
ENV WAR_URL=http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip 

#
# Build (1/ ) Add required fonts and utilities
RUN echo "deb http://httpredir.debian.org/debian stretch contrib" >> /etc/apt/sources.list
RUN set -x \
	&& apt-get -y update \
	&& apt-get install -y ttf-mscorefonts-installer fonts-cantarell lmodern ttf-aenigma ttf-georgewilliams ttf-bitstream-vera ttf-sjfonts tv-fonts \
        build-essential libapr1-dev libssl-dev default-jdk libnetcdf-dev wget zip curl --fix-missing \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

### Add GDAL native libraries if the build-arg GDAL_NATIVE = true
# EWC and JP2ECW are subjected to licence restrictions
RUN mkdir /tmp/resources \
    && if [ "$GDAL_NATIVE" = true ]; then \
        wget --progress=bar http://demo.geo-solutions.it/share/github/imageio-ext/releases/1.1.X/1.1.16/native/gdal/gdal-data.zip \
	        -O /tmp/resources/gdal-data.zip && \
        wget --progress=bar http://demo.geo-solutions.it/share/github/imageio-ext/releases/1.1.X/1.1.29/native/gdal/linux/gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz \
	        -O /tmp/resources/gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz && \
        unzip /tmp/resources/gdal-data.zip -d /usr/local && \
        mkdir /usr/local/gdal_native_libs && \
        tar -xvf /tmp/resources/gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz -C /usr/local/gdal_native_libs; \
        apt-get update; \
        apt-get install -y gdal-bin libgdal-java --fix-missing; \
    fi;
# If using GDAL make sure extension is downloaded
RUN if [ "$GDAL_NATIVE" = true ] && [ ! -f /tmp/resources/plugins/geoserver-gdal-plugin.zip ]; then \
	wget --progress=bar -c http://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-gdal-plugin.zip \
	-O /tmp/resources/plugins/geoserver-gdal-plugin.zip; \
fi;
###

ENV \
    GEOSERVER_DATA_DIR=${GEOSERVER_DATA_DIR} \
    # Opinionated : deploy base extensions
    STABLE_EXTENSIONS="monitor,importer,control-flow,inspire,gdal" \
    #COMMUNITY_EXTENSIONS="backup-restore,geostyler,imagemosaic-jdbc,importer-jdbc,wps-download" \
    GDAL_DATA=/usr/local/gdal_data \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/apr/lib:/opt/libjpeg-turbo/lib64:/usr/lib:/usr/lib/x86_64-linux-gnu" \
    MAX_FILTER_RULES=20 \
    # CSRF disabled to enable proper AJAX work (https://docs.geoserver.org/stable/en/user/security/webadmin/csrf.html)
    GEOSERVER_CSRF_DISABLED=true    

#
# Build (2/ ) Download & deploy GeoServer
RUN mkdir ${GEOSERVER_DATA_DIR} \
    # Get and deploy Geoserver version
	&& wget -c --progress=bar --no-check-certificate ${WAR_URL} -O /tmp/resources/geoserver-${GEOSERVER_VERSION}.zip \
	&& unzip /tmp/resources/geoserver-${GEOSERVER_VERSION}.zip -d /tmp/geoserver \
	&& unzip /tmp/geoserver/geoserver.war -d ${CATALINA_HOME}/webapps/geoserver \
    # Move necessary files outside default deployment directory
    && cp -r ${CATALINA_HOME}/webapps/geoserver/data/user_projections ${GEOSERVER_DATA_DIR} \
    && cp -r ${CATALINA_HOME}/webapps/geoserver/data/security ${CATALINA_HOME} \
    && rm -rf ${CATALINA_HOME}/webapps/geoserver/data \
    && rm -rf /tmp/geoserver \
    # Remove Tomcat manager, docs, and examples
    && rm -rf ${CATALINA_HOME}/webapps/ROOT \
    && rm -rf ${CATALINA_HOME}/webapps/docs \
    && rm -rf ${CATALINA_HOME}/webapps/examples \
    && rm -rf ${CATALINA_HOME}/webapps/host-manager \
    && rm -rf ${CATALINA_HOME}/webapps/manager; 

###
# Build (3/ ) Get & deploy extensions 
# -> 3.1 Get stable extensions into /tmp/stable_plugins then unzip into /tmp/gs_plugins and move *.jar files into GS libs folders
RUN mkdir -p /tmp/ressources/stable_plugins /tmp/ressources/community_plugins /tmp/ressources/gs_plugins \
    && exts_path="/tmp/ressources/stable_plugins" \
    && jar_dir="/tmp/ressources/gs_plugins" \
    && gs_majorver=$(echo "${GEOSERVER_VERSION}" | grep -o '[0-9].[0-9][0-9]'); \
    # Get all required extensions
    for ext in $(echo "${STABLE_EXTENSIONS}" | tr ',' ' '); \
      do \
        if [ -z "${STABLE_EXTENSIONS}" ]; \
          then echo "No stable plugin marked for deployment"; \
        else \
          echo "Enabling ${ext} stable plugin for GeoServer ${gs_majorver}"; \
          zipfile="https://build.geoserver.org/geoserver/${gs_majorver}.x/ext-latest/geoserver-${gs_majorver}-SNAPSHOT-${ext}-plugin.zip"; \
          wget -c --progress=bar --no-check-certificate ${zipfile} -O ${exts_path}/geoserver-${gs_majorver}-SNAPSHOT-${ext}-plugin.zip \
          && unzip ${exts_path}/geoserver-${gs_majorver}-SNAPSHOT-${ext}-plugin.zip -d ${jar_dir}; \
        fi; \
      done; \
    # Deploy all *jar files into WEB-INF/lib directory
    mv ${jar_dir}/*.jar ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/ \
    && rm -rf ${jar_dir}/* && rm -rf ${exts_path}/*
#
# -> 3.2 Get community extensions into /tmp/community_plugins then unzip into /tmp/gs_plugins and move *.jar files into GS libs folders
RUN exts_path="/tmp/ressources/community_plugins" \
    && jar_dir="/tmp/ressources/gs_plugins" \
    && gs_majorver=$(echo "${GEOSERVER_VERSION}" | grep -o '[0-9].[0-9][0-9]'); \
     # Get all required extensions
    for ext in $(echo "${COMMUNITY_EXTENSIONS}" | tr ',' ' '); \
      do \
        if [ -z "${COMMUNITY_EXTENSIONS}" ]; \
          then echo "No community extension marked for deployment"; \
        else \
          echo "Enabling ${ext} community plugin for GeoServer ${gs_majorver}"; \
          zipfile="https://build.geoserver.org/geoserver/${gs_majorver}.x/community-latest/geoserver-${gs_majorver}-SNAPSHOT-${ext}-plugin.zip"; \
          wget -c --progress=bar --no-check-certificate ${zipfile} -O ${exts_path}/geoserver-${gs_majorver}-SNAPSHOT-${ext}-plugin.zip \
          && unzip ${exts_path}/geoserver-${gs_majorver}-SNAPSHOT-${ext}-plugin.zip -d ${jar_dir}; \
        fi; \
      done;
    # Deploy all *jar files into WEB-INF/lib directory
   # mv ${jar_dir}/*.jar ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/ \
   # && rm -rf ${jar_dir} && rm -rf ${exts_path}
###

#
# Build (4/ ) Enable CORS
RUN sed -i '\:</web-app>:i\
<filter>\n\
    <filter-name>CorsFilter</filter-name>\n\
    <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>\n\
    <init-param>\n\
        <param-name>cors.allowed.origins</param-name>\n\
        <param-value>*</param-value>\n\
    </init-param>\n\
    <init-param>\n\
        <param-name>cors.allowed.methods</param-name>\n\
        <param-value>GET,POST,HEAD,OPTIONS,PUT</param-value>\n\
    </init-param>\n\
</filter>\n\
<filter-mapping>\n\
    <filter-name>CorsFilter</filter-name>\n\
    <url-pattern>/*</url-pattern>\n\
</filter-mapping>' ${CATALINA_HOME}/webapps/geoserver/WEB-INF/web.xml

#
# Build (5/ ) Tomcat environment
ENV CATALINA_OPTS "-server -Djava.awt.headless=true \
	-Xms${INITIAL_MEMORY} -Xmx${MAXIMUM_MEMORY} -XX:+UseConcMarkSweepGC -XX:NewSize=48m -DGEOSERVER_DATA_DIR=${GEOSERVER_DATA_DIR}"

# Create tomcat user to avoid root access. 
RUN addgroup --gid 1099 tomcat && useradd -m -u 1099 -g tomcat tomcat \
    && chown -R tomcat:tomcat . \
    && chown -R tomcat:tomcat ${GEOSERVER_DATA_DIR} \
    && chown -R tomcat:tomcat ${CATALINA_HOME}/webapps/geoserver/

ADD conf/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/bin/sh", "/usr/local/bin/entrypoint.sh"]