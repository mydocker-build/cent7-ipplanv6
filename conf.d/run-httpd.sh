#!/bin/bash

DIR="/var/www/html"

# Check if /var/www/html empty or not
if [ "$(ls -A $DIR)" ]; then
     echo "Enjoy your IPPlan ...!"
else
    echo "Copy IPPlan source to webroot ...!"
    cp -r /usr/src/ipplanv6/* $DIR
    chmod -R 750 $DIR
    chown -R root.apache $DIR
fi

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -rf /run/httpd/* /tmp/httpd*

exec /usr/sbin/apachectl -DFOREGROUND
