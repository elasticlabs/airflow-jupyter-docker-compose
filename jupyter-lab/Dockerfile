FROM apache/airflow:2.0.1-python3.7

# Apache airflow extras selection
ARG AIRFLOW_EXTRAS="async,amazon,celery,docker,dask,elasticsearch,ftp,http,google,postgres,redis,sftp,ssh,statsd,virtualenv"
# Conda version and checksum
# Check https://repo.continuum.io/miniconda/
ENV MINICONDA_VERSION="4.9.2"
ARG miniconda_checksum="3143b1116f2d466d9325c206b7de88f7"
# Conda install required variables
# CONDA_PYTHON_VERSION : version without separator "."
ARG CONDA_PYTHON_VERSION=37
ARG CONDA_DIR=/opt/conda

# A few basics
ENV SHELL /bin/bash
ARG NB_USER="airflow"
# Mapping for the "fix permissions script"
ARG NB_UID=$AIRFLOW_UID
ARG NB_GID=$AIRFLOW_GID

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        vim-tiny \
        nano-tiny \
        wget \
        unzip \
        bzip2 \
        ca-certificates \
        curl \
        sudo \
        jq \
        locales \
        fonts-liberation \
        ffmpeg \
        dvipng \
        cm-super \
        inkscape \
        jed \
        libsm6 \
        libxext-dev \
        libxrender1 \
        lmodern \
        netcat \
        # ---- nbconvert dependencies ----
        texlive-xetex \
        texlive-fonts-recommended \
        texlive-plain-generic \
        # ----
        tzdata \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/nano nano /bin/nano-tiny 10 \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# Deploy extra packages
RUN pip install pyowm \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.profile \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc

# Configure some required variables
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    HOME=${AIRFLOW_HOME}
    
# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
# hadolint ignore=SC2016
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
   # Add call to conda init script see https://stackoverflow.com/a/58081608/4413446
   echo 'eval "$(command conda shell.bash hook 2> /dev/null)"' >> /etc/skel/.bashrc 

# Make sure user and conda directories are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

ENV PATH=${CONDA_DIR}/bin:$PATH

USER $NB_UID
WORKDIR ${CONDA_DIR}

# Download miniconda and validate checksum
RUN wget https://repo.continuum.io/miniconda/Miniconda3-py${CONDA_PYTHON_VERSION}_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${miniconda_checksum} *Miniconda3-py${CONDA_PYTHON_VERSION}_${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c -

#Deploy miniconda
RUN /bin/bash Miniconda3-py${CONDA_PYTHON_VERSION}_${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-py${CONDA_PYTHON_VERSION}_${MINICONDA_VERSION}-Linux-x86_64.sh

# Conda configuration see https://conda.io/projects/conda/en/latest/configuration.html
ENV PATH=${CONDA_DIR}/bin:$PATH
RUN echo "conda ${MINICONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda config --system --set channel_priority strict && \
    # For reference -> https://docs.anaconda.com/mkl-optimizations/
    conda install --repodata-fn repodata.json --quiet --yes conda-forge::blas=*=openblas && \
    conda update --all --quiet --yes && \
    conda clean -tipy && \
    rm -rf ${HOME}/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions ${HOME}
    # Activate conda environment
    #ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    #echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    #echo "conda activate base" >> ~/.bashrc

RUN conda install --repodata-fn repodata.json --quiet --yes \
    notebook=6.1.4 \
    ecmwf-api-client \
    jupyterhub=1.2.1 \
    jupyterlab=2.2.9 && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf ${HOME}/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions ${HOME}

# Essential python data analysis librairies
RUN conda install --repodata-fn repodata.json -c conda-forge --yes --freeze-installed \
        dask \
        matplotlib-base \
        numpy \
        pandas \
        panel  \
        pytables \
        scipy \
        scikit-image \
        scikit-learn \
        seaborn \
        statsmodels \
        xarray \
        # Jupyter and Airflow framework specific librairie
        appmode \
        ipywidgets \
        ipyleaflet \
        jupyter_nbextensions_configurator \
        jupyter_contrib_nbextensions \
        papermill \
        psycopg2 \
        cloudpickle \
        # EO / Weather specific
        bokeh \
        bottleneck \
        cartopy \
        cmocean \
        descartes \
        geos \
        geopandas \
        iris \
        iris-grib \
        # metpy
        # metview-batch
        magics \
        netcdf4 \
        protobuf \
        pynio \
        shapely \
        siphon \
        tini \
    # Cleanup tasks as from https://jcristharif.com/conda-docker-tips.html
    && conda clean -tipsy \
    && fix-permissions $CONDA_DIR \
    && fix-permissions ${HOME} \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
    && find /opt/conda/lib/python*/site-packages/bokeh/server/static -follow -type f -name '*.js' ! -name '*.min.js' -delete

# Jupyter
# Activate useful extensions
RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    jupyter nbextensions_configurator enable && \
    jupyter nbextension enable collapsible_headings/main && \
    jupyter nbextension enable rubberband/main && \
    jupyter nbextension enable toc2/main && \
    jupyter nbextension enable codefolding/main && \
    jupyter nbextension enable scratchpad/main && \
    jupyter nbextension enable --py widgetsnbextension && \
    # jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf ${HOME}/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions ${HOME}

# JupyterLab 
# Useful extensions deployment. Check this URL for most recent compatibilities
# https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager@^2.0.0 --no-build && \
    jupyter labextension install @bokeh/jupyter_bokeh@^2.0.0 --no-build && \
    jupyter labextension install jupyter-matplotlib@^0.7.2 --no-build && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager jupyter-leaflet && \
    #jupyter labextension install @mflevine/jupyterlab_html && \
    jupyter labextension install jupyterlab-plotly && \
    #jupyter labextension install jupyterlab_voyager && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "${HOME}/.cache/yarn" && \
    rm -rf "${HOME}/.node-gyp" && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf ${HOME}/.cache/yarn && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "${HOME}"

# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "${HOME}"

# Import matplotlib once to build the font cache.
ENV XDG_CACHE_HOME="${HOME}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "${HOME}"

WORKDIR $HOME
# Copy pre generated Jupyter configuration file
# Enable write access to Jupyter Lab notebooks
COPY jupyter_notebook_config.py ${HOME}/.jupyter/jupyter_notebook_config.py
RUN for dir in dags notebooks; \
       do \
         echo "[INFO] Creating ${HOME}/${dir} volume directory"; \
         mkdir -p ${dir}; \
         chmod 777 ${dir}; \
         echo 'Place here '${dir}' files' > ${HOME}/${dir}/README.md; \
      done;

ENTRYPOINT [ "tini" , "-g" , "--"]
CMD ["start-notebook.sh"]

# Copy local files as late as possible to avoid cache busting
#COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

# Fix permissions on /etc/jupyter as root
USER root
RUN fix-permissions /etc/jupyter/

# Switch back to user "airflow" to avoid accidental container runs as root
USER $NB_UID

WORKDIR ${HOME}
