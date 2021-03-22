FROM puckel/docker-airflow:1.10.9 AS conda-build

ENV SHELL /bin/bash
USER root

# Conda install required variables
# CONDA_PYTHON_VERSION : version without separator "."
ARG CONDA_PYTHON_VERSION=37
ARG CONDA_DIR=/opt/conda

# Install conda and check the MD5 sum provided on the download site
# Check https://repo.continuum.io/miniconda/
ENV MINICONDA_VERSION="4.9.2"
ARG miniconda_checksum="3143b1116f2d466d9325c206b7de88f7"

# Install basic utilities
RUN apt-get update  --fix-missing \
    && apt-get install -y --no-install-recommends \
        git \
        wget \
        unzip \
        bzip2 \
        build-essential \
        ca-certificates \
        curl \
        sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# Download miniconda and validate checksum
RUN wget https://repo.continuum.io/miniconda/Miniconda3-py${CONDA_PYTHON_VERSION}_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${miniconda_checksum} *Miniconda3-py${CONDA_PYTHON_VERSION}_${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c -

#Deploy miniconda
RUN /bin/bash Miniconda3-py${CONDA_PYTHON_VERSION}_${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-py${CONDA_PYTHON_VERSION}_${MINICONDA_VERSION}-Linux-x86_64.sh

# Conda configuration see https://conda.io/projects/conda/en/latest/configuration.html
ENV PATH=${CONDA_DIR}/bin:$PATH
RUN echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda config --system --set channel_priority strict && \
    # For reference -> https://docs.anaconda.com/mkl-optimizations/
    conda install --repodata-fn repodata.json --quiet --yes conda-forge::blas=*=openblas \
    conda-pack && \
    #
    conda update --all --quiet --yes && \
    conda clean --all -f -y && \
    rm -rf ${HOME}/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions ${HOME}

# Deploy all packages and requirements into a clean Conda environment
# as defined in the "packages/environment-jupyter-airflow.yml"
WORKDIR ${CONDA_DIR}
COPY ./packages packages
RUN conda env create -f packages/environment-jupyter-airflow.yml \
    && conda activate jupyter-airflow

# Cleanup tasks as from https://jcristharif.com/conda-docker-tips.html
#RUN conda clean -tipsy && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions ${HOME} && \
#    find /opt/conda/ -follow -type f -name '*.a' -delete && \
#    find /opt/conda/ -follow -type f -name '*.pyc' -delete && \
#    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
#    find /opt/conda/lib/python*/site-packages/bokeh/server/static -follow -type f -name '*.js' ! -name '*.min.js' -delete

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
    jupyter notebook --generate-config

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

#
# Package our CONDA environment for deployment on target container
ARG CONDA_PACK_NAME="conda-pack-jupyter-airflow-py38"
#
RUN conda-pack -n ${CONDA_PACK_NAME} -o /tmp/conda-pack-env.tar \
    && mkdir /${CONDA_PACK_NAME} \
    && cd /${CONDA_PACK_NAME} \
    && tar xf /tmp/conda-pack-env.tar \
    && rm -f /tmp/conda-pack-env.tar

#
#  Build stage -> 2 
#    - conda-pack deployment
#    - common image for : airflow + workers / schedulers / webservers + jupyterlab
#
FROM puckel/docker-airflow:1.10.9

ARG NB_USER="airflow"
ARG NB_UID="1000"
ARG NB_GID="1000"
ARG CONDA_DIR=/opt/conda

USER root

# Install useful utilities
RUN export PATH=/usr/local/airflow/.local/bin:$PATH \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.profile \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc \
    && apt-get update --fix-missing \
    && apt-get install -yq \
       build-essential \
       emacs-nox \
       vim-tiny \
       git \
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
       jq \
       tzdata \
       unzip \
       nano-tiny \
       wget \
       bzip2 \
       ca-certificates \
       curl \
       git \
       sudo \
       locales \
       fonts-liberation \
       ffmpeg \
       dvipng \
       cm-super \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/nano nano /bin/nano-tiny 10 \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# Configure some required variables
ENV SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
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

#
# Conda unpack
# (https://conda.github.io/conda-pack/)

# Prepare environment
ENV CONDA_DIR=/opt/conda \
    PATH=${CONDA_DIR}/bin:$PATH \
    USER=$NB_UID

# Copy / from the previous stage:
COPY --from=conda-build //${CONDA_PACK_NAME} ${CONDA_DIR}/

# Test that as it is, the environment actually works
# 
RUN source ${CONDA_DIR}/bin/activate \
    && python -c "import numpy; print('Conda unpack successful! Let's cleanup the environment!');" \
    && conda-unpack \
    && fix-permissions $CONDA_DIR \
    && fix-permissions ${HOME}
    # Activate conda environment
    #ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    #echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    #echo "conda activate base" >> ~/.bashrc

# Install Tini
RUN conda install --repodata-fn repodata.json --quiet --yes 'tini=0.18.0' && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions ${HOME}

# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "${HOME}"

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="${HOME}/.cache/"
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" \
    && fix-permissions "${HOME}"

USER $NB_UID
WORKDIR $HOME

# Copy pre generated Jupyter configuration file
# Enable write access to Jupyter Lab notebooks
COPY jupyter_notebook_config.py /usr/local/airflow/.jupyter/jupyter_notebook_config.py
RUN for dir in dags notebooks; \
       do \
         echo "[INFO] Creating ${dir} volume directory"; \
         mkdir -p ${dir}; \
         chmod 777 ${dir}; \
         echo 'Place here '${dir}' files' > /usr/local/airflow/${dir}/README.md; \
      done;

VOLUME ["/usr/local/airflow/dags", "/usr/local/airflow/notebooks"]
ENTRYPOINT [ "tini" , "-g" , "--"]
CMD ["start-notebook.sh"]

# Copy local files as late as possible to avoid cache busting
#COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

# For airflow, copy airfow config file
COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

# Fix permissions on /etc/jupyter as root
USER root
RUN fix-permissions /etc/jupyter/

# Switch back to user "airflow" to avoid accidental container runs as root
USER $NB_UID

WORKDIR /usr/local/airflow