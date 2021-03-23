FROM dpage/pgadmin4:latest
LABEL maintainer="Elasticlabs <contact@elasticlabs.co>"

# >> Configuration file creation
# Create 'servers.json' configuration file
# USER root
# RUN echo -e $'{ \n\
#     "Servers": { \n\
#         "1": { \n\
#             "Name": "Apache Airflow", \n\
#             "Group": "Servers", \n\
#             "Host": "postgre", \n\
#             "Port": 5432, \n\
#             "MaintenanceDB": "airflow", \n\
#             "Username": "airflow", \n\
#             "SSLMode": "prefer", \n\
#             "PassFile": "/pgpassfile" \n\
#         } \n\
#         "2": { \n\
#             "Name": "GeoServer DB", \n\
#             "Group": "Servers", \n\
#             "Host": "postgres", \n\
#             "Port": 5432, \n\
#             "MaintenanceDB": "geoserver", \n\
#             "Username": "airflow", \n\
#             "SSLMode": "prefer", \n\
#             "PassFile": "/pgpassfile" \n\
#         } \n\
#     } \n\
# }' > /pgadmin4/servers.json
