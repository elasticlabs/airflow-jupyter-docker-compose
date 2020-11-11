FROM puckel/docker-airflow:1.10.9

COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
ENV SHELL /bin/bash

COPY requirements.txt /requirements.txt
RUN export PATH=/usr/local/airflow/.local/bin:$PATH \
    && pip install --upgrade pip\
    && pip install -r /requirements.txt \
    && pip install --user jupyter \
    && pip install --user jupyterlab \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.profile \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc \
    && jupyter notebook --generate-config

# Copy pre generated Jupyter configuration file
# Enable write access to Jupyter Lab notebooks
COPY ./jupyter_notebook_config.py /usr/local/airflow/.jupyter/jupyter_notebook_config.py
RUN for dir in dags notebooks; \
       do \
         echo "[INFO] Creating ${dir} volume directory"; \
         mkdir -p ${dir}; \
         chmod 777 ${dir}; \
         echo 'Place here '${dir}' files' > /usr/local/airflow/${dir}/README.md; \
      done;

VOLUME ["/usr/local/airflow/dags", "/usr/local/airflow/notebooks"]
