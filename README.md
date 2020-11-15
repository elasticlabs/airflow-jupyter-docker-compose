# airflow-jupyter-docker-compose
Orchestration of data science and earth observation models in Apache Airflow, scale-up with Celery Executor, experiment with jupyter notebook using a docker containers composition. Based on `https://github.com/puckel/docker-airflow` works.

## Commands to deploy and manage the stack behind an HTTPS automated proxy: 
* Ensure that appropriate DNS record for `airflow` base URL is created and resolve well. 
* Ensure that your automated nginx-proxy (e.g. ) is up and running.
* Create the `airflow-proxy` network -> `sudo docker network create airflow-proxy`
* Attach the new network to the existing `nginx-proxy` container to ensure proper proxy operations -> `sudo docker network connect airflow-proxy <nginx-proxy container name>`
* Bring up the whole stack ->  `sudo docker-compose up -d --build`

## Stack management
* Stop containers : `sudo docker-compose down`
* View Container : `sudo docker ps`
* Go inside a container : `sudo docker-compose exec -it <service-id> bash`
* See logs of a container: `sudo docker logs <service-id>`
* Monitor containers : `sudo docker stats`

## Available URL list
* `airflow.<your-awesome-domain.ltd>` -> airflow web UI
* `airflow.<your-awesome-domain.ltd>/flower` -> Flower, celery workers Web UI
* `airflow.<your-awesome-domain.ltd>/pgadmin` -> pgadmin4
* `airflow.<your-awesome-domain.ltd>/jupyter` -> jupyter notebook (default password : notebook)

## Deployed librairies
Please find below the included choice of librairies and associated reference URL for documentation and examples

### Essential python librairies for data analysis
| Library | Desciption | Resources |
|---|---|---|
| bokeh | The Bokeh Visualization Library | https://bokeh.org/ |
| bottleneck | Bottleneck is a collection of fast, NaN-aware NumPy array functions written in C. Working with `pandas` and `xarray` | https://github.com/pydata/bottleneck |
| dask | Dask provides advanced parallelism for analytics, enabling performance at scale for the tools you love. | https://dask.org/ |
| matplotlib-base | Matplotlib is a comprehensive library for creating static, animated, and interactive visualizations in Python. | https://matplotlib.org/ |
| numpy | The fundamental package for scientific computing with Python. | https://numpy.org/ |
| panel | A high-level app and dashboarding solution for Python. | https://panel.holoviz.org/index.html |
| pytables | PyTables is a package for managing hierarchical datasets and designed to efficiently and easily cope with extremely large amounts of data. | https://www.pytables.org/ |
| scipy | SciPy (pronounced “Sigh Pie”) is a Python-based ecosystem of open-source software for mathematics, science, and engineering. In particular | https://www.scipy.org/ |
| scikit-image | Image processing in Python | https://scikit-image.org/ |
| scikit-learn | Machine Learning in Python | https://scikit-learn.org/stable/ |
| seaborn | Seaborn is a Python data visualization library based on matplotlib. It provides a high-level interface for drawing attractive and informative statistical graphics. | http://seaborn.pydata.org/ |
| statsmodels |  |  |
| xarray | xarray (formerly xray) is an open source project and Python package that makes working with labelled multi-dimensional arrays simple, efficient, and fun! | http://xarray.pydata.org/en/stable/ |

### Jupyter and Airflow framework specific librairies
| Library | Desciption | Resources |
|---|---|---|
| papermill | Papermill is a tool for parameterizing and executing Jupyter Notebooks. | https://papermill.readthedocs.io/en/latest/ |
| psycopg2 | Psycopg is the most popular PostgreSQL database adapter for the Python programming language. | https://www.psycopg.org/docs/ |

* JupyterLab extensions
| Library | Desciption | Resources |
|---|---|---|
| appmode | A Jupyter extensions that turns notebooks into web applications. | https://github.com/oschuett/appmode |
| ipywidgets | Widgets are eventful python objects that have a representation in the browser, often as a control like a slider, textbox, etc. | https://ipywidgets.readthedocs.io/en/stable/examples/Widget%20List.html |
| ipyleaflet | Interactive maps in the Jupyter notebook. | https://ipyleaflet.readthedocs.io/en/latest/ |
| jupyterlab-manager | A JupyterLab extension for Jupyter/IPython widgets. | https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager |
| jupyter_bokeh | An extension for rendering Bokeh content in JupyterLab notebooks | https://bokeh.org/ |
| jupyter-matplotlib | An extension for rendering Matplotlib content in JupyterLab notebooks | https://matplotlib.org/ |
| jupyterlab-plotly | The plotly Python library is an interactive, open-source plotting library that supports over 40 unique chart types covering a wide range of statistical, financial, geographic, scientific, and 3-dimensional use-cases. | https://plotly.com/python/getting-started/ |
| jupyterlab-voyager | JupyterLab extension visualize data with Voyager | https://data-voyager.gitbook.io/voyager/ |

# Geo / EO / Weather specific
| Library | Desciption | Resources |
|---|---|---|
| cartopy | Cartopy is a Python package designed for geospatial data processing in order to produce maps and other geospatial data analyses. | https://scitools.org.uk/cartopy/docs/latest/ |
| cmocean | This package contains colormaps for commonly-used oceanographic variables. | https://matplotlib.org/cmocean/ |
| descartes | Use Shapely or GeoJSON-like geometric objects as matplotlib paths and patches | https://pypi.org/project/descartes/ |
| ecwmf-api-client | ECMWF WebAPI is a set of services developed by ECMWF to allow users from the outside to access some internal features and data of the centre. | https://confluence.ecmwf.int/display/WEBAPI/ECMWF+Web+API+Home |
| iris | A powerful, format-agnostic, community-driven Python library for analysing and visualising Earth science data. | https://scitools.org.uk/iris/docs/latest/ |
| iris-grib | The library iris-grib provides functionality for converting between weather and climate datasets that are stored as GRIB files and Iris cubes. | https://iris-grib.readthedocs.io/en/stable/ |
| geos | GEOS (Geometry Engine - Open Source) is a C++ port of the ​JTS Topology Suite (JTS). It aims to contain the complete functionality of JTS in C++. | https://trac.osgeo.org/geos/ |
| geopandas | GeoPandas is an open source project to make working with geospatial data in python easier. GeoPandas extends the datatypes used by pandas to allow spatial operations on geometric types. | https://geopandas.org/ |
| metpy | MetPy is a collection of tools in Python for reading, visualizing, and performing calculations with weather data. | https://unidata.github.io/MetPy/latest/index.html |
| metview | Python interface to Metview meteorological workstation and batch system | https://software.ecmwf.int/metview |
| magics | Python interface to Magics meteorological plotting package. | https://github.com/ecmwf/magics-python |
| netcdf4 | netcdf4-python is a Python interface to the netCDF C library. | http://unidata.github.io/netcdf4-python/netCDF4/index.html |
| protobuf | Protocol buffers are a language-neutral, platform-neutral extensible mechanism for serializing structured data. | https://developers.google.com/protocol-buffers/ |
| pynio | PyNIO is a multi-format data I/O package with a NetCDF-style interface. | http://www.pyngl.ucar.edu/Nio.shtml |
| shapely | Manipulation and analysis of geometric objects in the Cartesian plane. | https://shapely.readthedocs.io/en/stable/project.html |
| siphon | A collection of Python utilities for retrieving atmospheric and oceanic data from remote sources, focusing on being able to retrieve data from Unidata data technologies, such as the THREDDS data server. | https://unidata.github.io/siphon/latest/examples/index.html |
