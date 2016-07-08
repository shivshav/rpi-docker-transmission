#!/bin/bash

set -e

FIRST_RUN=first-run.sh
if [[ -x /$FIRST_RUN ]]; then
    /$FIRST_RUN
fi

echo "Start up transmission services."

exec su -s /bin/bash -c "/usr/bin/supervisord"
