FROM python:3.10-bullseye

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install \
    build-essential \
    python3-docutils \
    udev \
    systemd \
    cmake \
    autoconf \
    libtool \
    libdbus-1-dev \
    libudev-dev \
    libical-dev \
    libreadline-dev

RUN apt-get -y install libell-dev bluez bluez-meshd

WORKDIR /opt/build
COPY docker/scripts/install-json-c.sh .
RUN sh ./install-json-c.sh

# install bridge
WORKDIR /opt/hass-ble-mesh
COPY ./requirements.txt .
RUN pip3 install --upgrade pip && pip3 install "cython<3.0.0" wheel && pip install "pyyaml==6.0" --no-build-isolation && pip3 install -r requirements.txt

WORKDIR /opt/hass-ble-mesh
COPY ./gateway gateway

# mount config
WORKDIR /var/lib/bluetooth/mesh
VOLUME /var/lib/bluetooth/mesh
ENV GATEWAY_BASEDIR=/var/lib/bluetooth/mesh

# run bluetooth service and bridge
WORKDIR /opt/hass-ble-mesh/gateway
COPY docker/scripts/entrypoint.sh .
ENTRYPOINT [ "/bin/bash", "entrypoint.sh" ]
