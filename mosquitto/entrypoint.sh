#!/bin/bash -x

# Exit on errors
set -euo pipefail

# Add openHAB daemon user
NEW_USER_ID=${USER_ID:-999}
NEW_GROUP_ID=${GROUP_ID:-999}
echo "Starting with openHAB user id: $NEW_USER_ID and group id: $NEW_GROUP_ID"
if ! id -u openhab >/dev/null 2>&1; then
  if [ -z "$(getent group $NEW_GROUP_ID)" ]; then
    echo "Create group openhab with id ${NEW_GROUP_ID}"
    groupadd -g $NEW_GROUP_ID openhab
  else
    group_name=$(getent group $NEW_GROUP_ID | cut -d: -f1)
    echo "Rename group $group_name to openhab"
    groupmod --new-name openhab $group_name
  fi
  echo "Create user openhab with id ${NEW_USER_ID}"
  adduser -u $NEW_USER_ID --disabled-password --gecos '' --home "${APPDIR}" --gid $NEW_GROUP_ID openhab
fi

Generate default Mosquitto configuration file if none exists
if [ ! -e ${MOSQUITTO_CONFIG_PATH} ]; then
  influxd config >${MOSQUITTO_CONFIG_PATH}
  echo "Creating default "
fi

# Start Mosquitto Daemon with configuration in /mosquitto/conf/mosquitto.conf
echo "Starting Mosquitto in interactive mode with $@"
exec "$@" 
