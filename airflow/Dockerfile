FROM puckel/docker-airflow:1.10.9

COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
ENV SHELL /bin/bash

RUN export PATH=/usr/local/airflow/.local/bin:$PATH \
    && pip install --upgrade pip \
    && pip install --user jupyter \
    && pip install --user jupyterlab \
    && pip install papermill \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.profile \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc \
    && jupyter notebook --generate-config \
    && apt-get update --fix-missing \
    && apt-get install -y wget bzip2 ca-certificates curl git 

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


# Configure Conda environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash

ENV PATH=${CONDA_DIR}/bin:$PATH

USER root

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    # Conda configuration see https://conda.io/projects/conda/en/latest/configuration.html
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda config --system --set channel_priority strict &&\
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# Deploy required libraries using miniconda environment
RUN conda install --quiet --yes conda-forge::blas=*=openblas
RUN conda install -c conda-forge --yes --freeze-installed \
    nomkl \
    metpy \
    siphon \
    cartopy \
    netcdf4 \
    xarray \
    ffmpeg \
    iris \
    scikit-learn \
    seaborn \
    magics \
    numpy==1.16.3 \
    pandas==0.24.2 \
    tini==0.18.0 \
    # Cleanup tasks as from https://jcristharif.com/conda-docker-tips.html
    && conda clean -tipsy \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
    && find /opt/conda/lib/python*/site-packages/bokeh/server/static -follow -type f -name '*.js' ! -name '*.min.js' -delete

USER airflow
WORKDIR /usr/local/airflow
VOLUME ["/usr/local/airflow/dags", "/usr/local/airflow/notebooks"]
ENTRYPOINT [ "/usr/bin/tini", "--" ]