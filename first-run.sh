#!/bin/bash

CONFIG=settings.json
CONFIG_DIR=/etc/transmission-daemon
OVERWRITE_CONFIG=${OVERWRITE_CONFIG:-false}
TORRENT_DIR=/var/lib/transmission-daemon/

mkdir -p $TORRENT_DIR/{completed,incomplete,watch}

# Check to make sure required env vars are set
if [[ -z "$TR_USERNAME" || -z "$TR_PASSWORD" ]]; then
    echo "No values given for transmission web access. Recommend recreating container with '\$TR_USERNAME', '\$TR_PASSWORD', and environment variables set."
    exit 1
fi

# Check for presence of a config file
if [[ ! -f $CONFIG_DIR/$CONFIG || "$OVERWRITE_CONFIG" = true ]]; then
    cp /${CONFIG}.template $CONFIG_DIR/$CONFIG

    sed -i "s/{{TR_USERNAME}}/${TR_USERNAME}/g" $CONFIG_DIR/$CONFIG
    sed -i "s/{{TR_PASSWORD}}/${TR_PASSWORD}/g" $CONFIG_DIR/$CONFIG
else
    echo "Current settings file will not be overwritten."
fi

echo "Initial setup finished"
# Remove the first-run script if it completes successfully once
rm /first-run.sh
