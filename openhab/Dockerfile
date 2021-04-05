#
FROM multiarch/debian-debootstrap:amd64-buster

# Set download URLs
ENV \
    JAVA_URL="https://cdn.azul.com/zulu/bin/zulu8.42.0.23-ca-jdk8.0.232-linux_x64.tar.gz" \
    OPENHAB_URL="https://bintray.com/openhab/mvn/download_file?file_path=org%2Fopenhab%2Fdistro%2Fopenhab%2F2.5.0%2Fopenhab-2.5.0.zip" \
    OPENHAB_VERSION="2.5.0"

# Set variables and locales.
ENV EXTRA_JAVA_OPTS="-Dpython.path=/usr/local/lib/python2.7/dist-packages:/usr/lib/python2.7/dist-packages -Duser.timezone=Europe/Amsterdam -Dgnu.io.rxtx.SerialPorts=/dev/ttyUSB0:/dev/ttyUSB1" \
    USER_ID="106" \
    GROUP_ID="114" \
    KARAF_EXEC="exec" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    OPENHAB_BACKUPS="/openhab/userdata/backup" \
    OPENHAB_CONF="/openhab/conf" \
    OPENHAB_HOME="/openhab" \
    OPENHAB_HTTP_PORT="5080" \
    OPENHAB_HTTPS_PORT="5443" \
    OPENHAB_LSP_PORT="5007" \
    OPENHAB_LOGDIR="/openhab/userdata/logs" \
    OPENHAB_USERDATA="/openhab/userdata"

# Set arguments on build
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Basic build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="EPL-2.0" \
    org.label-schema.name="openHAB" \
    org.label-schema.vendor="openHAB Foundation e.V." \
    org.label-schema.version=$VERSION \
    org.label-schema.description="An open source, technology agnostic home automation platform" \
    org.label-schema.url="https://www.openhab.com/" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/openhab/openhab-docker.git" \
    maintainer="openHAB <info@openhabfoundation.org>"

# Install basepackages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        arping \
        ca-certificates \
        curl \
        fontconfig \
        gosu \
        libcap2-bin \
        locales \
        locales-all \
        netbase \
        procps \
        tini \
        unzip \
        wget \
        zip && \
    chmod u+s /usr/sbin/arping && \
    ln -s -f /bin/true /usr/bin/chfn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## Install java
ENV JAVA_HOME='/usr/lib/java-8'
RUN wget -nv -O /tmp/java.tar.gz "${JAVA_URL}" && \
    mkdir "${JAVA_HOME}" && \
    tar --exclude='demo' --exclude='sample' --exclude='src.zip' -xf /tmp/java.tar.gz --strip-components=1 -C "${JAVA_HOME}" && \
    rm /tmp/java.tar.gz && \
    update-alternatives --install /usr/bin/java java "${JAVA_HOME}/bin/java" 50 && \
    update-alternatives --install /usr/bin/javac javac "${JAVA_HOME}/bin/javac" 50

## Install python
COPY requirements.txt /
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
   	jq \
   	python2.7 \
    python-dev \
   	python-pip \
   	python-setuptools \
   	python-wheel && \
    pip install -r /requirements.txt && \
    apt-get clean && \
   	rm -rf /var/lib/apt/lists/*

## Install openHAB
##  Set permissions for openHAB. Export TERM variable. See issue #30 for details!
RUN wget -nv -O /tmp/openhab.zip "${OPENHAB_URL}" && \
    unzip -q /tmp/openhab.zip -d "${OPENHAB_HOME}" -x "*.bat" "*.ps1" "*.psm1" && \
    rm /tmp/openhab.zip && \
    if [ ! -f "${OPENHAB_HOME}/runtime/bin/update.lst" ]; then touch "${OPENHAB_HOME}/runtime/bin/update.lst"; fi && \
    if [ ! -f "${OPENHAB_HOME}/runtime/bin/userdata_sysfiles.lst" ]; then wget -nv -O "${OPENHAB_HOME}/runtime/bin/userdata_sysfiles.lst" "https://raw.githubusercontent.com/openhab/openhab-distro/2.4.0/distributions/openhab/src/main/resources/bin/userdata_sysfiles.lst"; fi && \
    mkdir -p "${OPENHAB_LOGDIR}" && \
    touch "${OPENHAB_LOGDIR}/openhab.log" && \
    mkdir -p "${OPENHAB_HOME}/dist" && \
    cp -a "${OPENHAB_CONF}" "${OPENHAB_USERDATA}" "${OPENHAB_HOME}/dist" && \
    echo 'export TERM=${TERM:=dumb}' | tee -a ~/.bashrc
# COPY update.sh ${OPENHAB_HOME}/runtime/bin/update
# RUN chmod +x ${OPENHAB_HOME}/runtime/bin/update

## Expose volume with configuration and userdata dir
VOLUME ${OPENHAB_CONF} ${OPENHAB_USERDATA} ${OPENHAB_HOME}/addons

## Setup the Python openHAB core scripts
RUN wget -nv -O /tmp/openhab2-jython.zip "https://github.com/OH-Jython-Scripters/openhab2-jython/archive/master.zip" && \
    unzip /tmp/openhab2-jython.zip -d /tmp && \
    mkdir -p ${OPENHAB_CONF}/automation/jsr223/python/core && \
    mv /tmp/openhab-helper-libraries-master/Core/automation/jsr223/python/core/* ${OPENHAB_CONF}/automation/jsr223/python/core

## Copy the Jython addon to the addons directory
RUN mkdir -p ${OPENHAB_HOME}/addons
COPY org.openhab.core.automation.module.script.scriptenginefactory.jython-*.jar ${OPENHAB_HOME}/addons/.

# Copy startup scripts
COPY cont-init.d/ /etc/cont-init.d
RUN chmod -R +x /etc/cont-init.d

## Set working directory and entrypoint
WORKDIR ${OPENHAB_HOME}
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

## Execute command
CMD ["gosu", "openhab", "tini", "-s", "./start.sh"]
