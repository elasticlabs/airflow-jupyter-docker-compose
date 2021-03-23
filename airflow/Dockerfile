FROM apache/airflow:2.0.1-python3.7

ARG AIRFLOW_EXTRAS="async,amazon,celery,docker,dask,elasticsearch,ftp,http,google,postgres,redis,sftp,ssh,statsd,virtualenv"

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        vim-tiny \
        nano-tiny \
        wget \
        unzip \
        bzip2 \
        build-essential \
        ca-certificates \
        curl \
        sudo \
        jq \
        locales \
        fonts-liberation \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/nano nano /bin/nano-tiny 10 \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# Deploy extra packages
RUN pip install apache-airflow[${AIRFLOW_EXTRAS}]

# Configure some required variables
ENV SHELL=/bin/bash \
    NB_USER=$NB_USER \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

USER airflow

# Now we initialize the PostgreSQL backend
# https://airflow.apache.org/docs/apache-airflow/stable/howto/set-up-database.html#database-uri
RUN airflow db init