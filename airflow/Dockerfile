FROM puckel/docker-airflow:1.10.9

COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

COPY requirements.txt /requirements.txt
RUN pip install --upgrade pip\
    && pip install -r /requirements.txt \
    && pip install --user jupyter \
    && pip install --user jupyterlab \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.profile \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc