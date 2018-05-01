FROM ubuntu:16.04

RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& apt-get update && apt-get install -y locales \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Install some useful tools and dependencies for MRO
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		libcurl4-openssl-dev \
		libssl-dev \
		gcc \
		make \
    		cmake \
		less \
		git \
		wget \
		gfortran \
		unzip \
    		libssh2-1-dev \
		libgomp1 \
		libpango-1.0-0 \
		libxt6 \
		libsm6 \
		tzdata \
	&& rm -rf /var/lib/apt/lists/*

# Use major and minor vars to re-use them in non-interactive installation script
ENV MRO_VERSION_MAJOR 3
ENV MRO_VERSION_MINOR 4
ENV MRO_VERSION_BUGFIX 3
ENV MRO_VERSION $MRO_VERSION_MAJOR.$MRO_VERSION_MINOR.$MRO_VERSION_BUGFIX

WORKDIR /home/docker

## Donwload and install MRO & MKL
RUN curl -LO -# https://mran.blob.core.windows.net/install/mro/$MRO_VERSION/microsoft-r-open-$MRO_VERSION.tar.gz \
	&& tar -xzf microsoft-r-open-$MRO_VERSION.tar.gz
WORKDIR /home/docker/microsoft-r-open
RUN  ./install.sh -a -u

# Copy microsoft R ssl certificate
RUN ln -s /opt/microsoft/ropen/3.4.3/lib64/R/lib/microsoft-r-cacert.pem /etc/ssl/certs/microsoft-r-cacert.pem

# Reinstall curl
RUN R -q -e "install.packages('curl')"

# Clean up downloaded files
WORKDIR /home/docker

RUN rm microsoft-r-open-*.tar.gz && rm -r microsoft-r-open

CMD ["/bin/bash"]
##CMD ["R", "--no-save"]

