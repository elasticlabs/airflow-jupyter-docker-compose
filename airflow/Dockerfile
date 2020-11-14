FROM puckel/docker-airflow:1.10.9

COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
ENV SHELL /bin/bash
ARG NB_USER="airflow"
ARG NB_UID="1000"
ARG NB_GID="1000"

USER root
RUN export PATH=/usr/local/airflow/.local/bin:$PATH \
    && pip install --upgrade pip \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.profile \
    && echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc \
    && apt-get update --fix-missing \
    && apt-get install -yq --no-install-recommend \
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
       run-one \
       ffmpeg \
       dvipng \
       cm-super \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/nano nano /bin/nano-tiny 10

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure Conda environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    HOME=$HOME
ENV PATH=${CONDA_DIR}/bin:$PATH

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
# hadolint ignore=SC2016
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
   # Add call to conda init script see https://stackoverflow.com/a/58081608/4413446
   echo 'eval "$(command conda shell.bash hook 2> /dev/null)"' >> /etc/skel/.bashrc 

# Make sur user and conda directories are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

USER $NB_UID
WORKDIR $HOME
# Install conda as airflow and check the MD5 sum provided on the download site
ARG miniconda_checksum="d63adf39f2c220950a063e0529d4ff74"
# Check https://repo.anaconda.com/miniconda/
# Miniconda archive to install
ENV MINICONDA_VERSION="4.8.3" \
    CONDA_VERSION="4.9.0"

# Install conda as jovyan and check the md5 sum provided on the download site
ENV MINICONDA_VERSION="${miniconda_version}" \
    CONDA_VERSION="${conda_version}"

WORKDIR /tmp
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${miniconda_checksum} *Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    # Conda configuration see https://conda.io/projects/conda/en/latest/configuration.html
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda config --system --set channel_priority strict && \
    if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    conda install --quiet --yes "conda=${CONDA_VERSION}" && \
    conda install --quiet --yes pip && \
    conda update --all --quiet --yes && \
    conda clean --all -f -y && \
    rm -rf ${HOME}/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions ${HOME}

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

# Install Tini
RUN conda install --quiet --yes 'tini=0.18.0' && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions ${HOME}

# Install Jupyter Notebook, Lab, and Hub
# Generate a notebook server config
# Cleanup temporary files
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
RUN conda install --quiet --yes \
    'notebook=6.1.4' \
    'jupyterhub=1.2.1' \
    'jupyterlab=2.2.9' && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf ${HOME}/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions ${HOME}

# Deploy required libraries using miniconda environment
RUN conda install --quiet --yes conda-forge::blas=*=openblas
RUN conda install -c conda-forge --yes --freeze-installed \
    nomkl \
    metpy \
    siphon \
    cartopy \
    netcdf4 \
    xarray \
    iris \
    scikit-learn \
    seaborn \
    magics \
    numpy \
    pandas \
    bokeh \
    bottleneck \
    cloudpickle \
    matplotlib-base \
    protobuf \
    pytables \
    scipy \
    scikit-image \
    scikit-learn \
    psycopg2 \
    # Cleanup tasks as from https://jcristharif.com/conda-docker-tips.html
    && conda clean -tipsy \
    && fix-permissions $CONDA_DIR \
    && fix-permissions ${HOME} \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
    && find /opt/conda/lib/python*/site-packages/bokeh/server/static -follow -type f -name '*.js' ! -name '*.min.js' -delete && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    # Check this URL for most recent compatibilities
    # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^2.0.0 --no-build && \
    jupyter labextension install @bokeh/jupyter_bokeh@^2.0.0 --no-build && \
    jupyter labextension install jupyter-matplotlib@^0.7.2 --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "${HOME}/.cache/yarn" && \
    rm -rf "${HOME}/.node-gyp" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "${HOME}"

# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "${HOME}"

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="${HOME}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "${HOME}"

USER $NB_UID

WORKDIR $HOME
# Copy pre generated Jupyter configuration file
# Enable write access to Jupyter Lab notebooks
#COPY jupyter_notebook_config.py /usr/local/airflow/.jupyter/jupyter_notebook_config.py
#RUN for dir in dags notebooks; \
#       do \
#         echo "[INFO] Creating ${dir} volume directory"; \
#         mkdir -p ${dir}; \
#         chmod 777 ${dir}; \
#         echo 'Place here '${dir}' files' > /usr/local/airflow/${dir}/README.md; \
#      done;

VOLUME ["/usr/local/airflow/dags", "/usr/local/airflow/notebooks"]
ENTRYPOINT [ "tini" , "-g" , "--"]
CMD ["start-notebook.sh"]

# Copy local files as late as possible to avoid cache busting
COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

# Fix permissions on /etc/jupyter as root
USER root
RUN fix-permissions /etc/jupyter/

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

WORKDIR /usr/local/airflow