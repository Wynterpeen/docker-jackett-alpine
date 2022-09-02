#!/bin/bash

# Make user running the services
adduser -D -u $PUID abc

chown -R $PUID:$PGID "/etc/Jackett"

# Start jackett
su abc -s /bin/bash -c "/usr/bin/jackett/jackett" &

# Keep container running
tail -f /dev/null
