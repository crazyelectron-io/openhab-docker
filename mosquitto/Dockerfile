# ------------------------------------------------------------------------------
#             NOTE: THIS DOCKERFILE CREATES A MOSQUITTO CONTAINER
# ------------------------------------------------------------------------------

FROM debian:buster-slim

# Set variables and locales
ENV APPDIR="/mosquitto" \
    LC_ALL="C.UTF-8" \
    LANG="C.UTF-8" \
    LANGUAGE="C.UTF-8" \
    MOSQUITTO_PORT="1883" \
    MOSQUITTO_CONFIG_PATH="/mosquitto/config/mosquitto.conf"
    
# Set non-interactive APT mode during build
ARG DEBIAN_FRONTEND=noninteractive

# Install base packages
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        wget \
        gosu \
        libpcap-dev \
        locales \
        locales-all && \
    ln -s -f /bin/true /usr/bin/chfn && \
    apt-get install --no-install-recommends -y tini mosquitto && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add volume for Mosquitto
VOLUME ${APPDIR}

# Expose Mosquitto ports
EXPOSE ${MOSQUITTO_PORT}

# Set working directory and entrypoint
WORKDIR ${APPDIR}
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Set command
CMD ["gosu", "openhab", "tini", "-s", "mosquitto"]
