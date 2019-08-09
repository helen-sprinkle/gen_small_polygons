FROM rocker/rstudio:3.6.1

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    software-properties-common \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libmariadb-client-lgpl-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libsasl2-dev \
    lbzip2 \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libhdf4-alt-dev \
    libhdf5-dev \
    libjq-dev \
    liblwgeom-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libssl-dev \
    libudunits2-dev \
    netcdf-bin \
    postgis \
    protobuf-compiler \
    sqlite3 \
    tk-dev \
    libv8-3.14-dev \
    libprotobuf-dev \
    protobuf-compiler \
  && add-apt-repository -y ppa:opencpu/jq \
  && apt-get install -y libjq-dev \
  && install2.r --error \
    --deps TRUE \
    tidyverse \
    magrittr \
    ggplot2 \
    devtools \
    formatR \
    remotes \
    selectr \
    caTools \
    BiocManager \
    RColorBrewer \
    RandomFields \
    RNetCDF \
    classInt \
    deldir \
    gstat \
    hdf5r \
    lidR \
    mapdata \
    maptools \
    mapview \
    ncdf4 \
    proj4 \
    raster \
    rgdal \
    rgeos \
    rlas \
    sf \
    sp \
    spacetime \
    spatstat \
    spatialreg \
    spdep \
    geoR \
    geosphere \
    geojsonio \
    GISTools \
    tbart \
    ggvoronoi \
    tmap \
    ## from bioconductor
    && R -e "BiocManager::install('rhdf5')"