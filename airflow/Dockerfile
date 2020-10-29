FROM jupyter/scipy-notebook AS build

COPY environment.yml .

RUN conda env create -f environment.yml \
    && conda install -c conda-forge --quiet --yes \
    'mlflow=1.0.0' \
    'psycopg2' \
    'jupyterlab' \
    'notebook' \
    'conda-pack'

# Use conda-pack to create a standalone environment
# in /venv:
RUN conda-pack -n airflow -o /tmp/env.tar \
    && mkdir /usr/local/venv \ 
    && cd /usr/local/venv \
    && tar xf /tmp/env.tar \
    && rm /tmp/env.tar

# We've put venv in same path it'll be in final image,
# so now fix up paths:
RUN /usr/local/venv/bin/conda-unpack

# Now building the final image
FROM puckel/docker-airflow:1.10.9 AS runtime 

# Copy /venv from the previous stage:
COPY --from=build /venv /venv

# Airflow installation
COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
COPY requirements.txt /requirements.txt
RUN pip install --upgrade pip\
    && pip install -r /requirements.txt 

ENTRYPOINT source /usr/local/venv/bin/activate