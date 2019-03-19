#!/bin/bash

PDB_HOST=localhost
PDB_PORT=3306
INIT_TIMEOUT=60
INIT_SLEEP=10
SHUTDOWN_TIMEOUT=30
SHUTDOWN_SLEEP=5

finally=:
for var in DUMPDATE MYSQL_USER MYSQL_PASSWORD MYSQL_ROOT_PASSWORD ; do
    eval val="\"\$${var}\""
    if [[ -z $val ]] ; then
        echo ERROR: environment variable ${var} must be defined
        finally="exit 1"
    fi
done
eval ${finally}

PDB_LOGIN=${MYSQL_USER}
PDB_PASSWORD=${MYSQL_PASSWORD}
export PDB_HOST PDB_PORT PDB_LOGIN PDB_PASSWORD

/usr/local/bin/docker-entrypoint.sh mysqld &

init_elapsed=0
while [[ $init_elapsed -lt $INIT_TIMEOUT ]] ; do
    sleep $INIT_SLEEP
    (( init_elapsed += INIT_SLEEP ))
    healthcheck.sh -v
    if [ $? = 0 ] ; then
        read pid </var/run/mysqld/mysqld.pid
        echo "Killing mysqld (pid=${pid})"
        kill -s TERM "${pid}"
        shutdown_elapsed=0
        while [[ $shutdown_elapsed -lt $SHUTDOWN_TIMEOUT ]] ; do
            sleep $SHUTDOWN_SLEEP
            (( shutdown_elapsed += SHUTDOWN_SLEEP ))
            if [ ! -e /proc/${pid} ] ; then

                echo "Saving database..."
                tar czf /db.tgz /var/run/mysqld /var/lib/mysql || exit 1
                echo "${MYSQL_USER}" >/mysql_user.txt
                echo "${MYSQL_PASSWORD}" | sha256sum >/mysql_password.sha256
                exit 0
            fi
        done
        echo "Unable to shutdown mysqld!" >&2
        exit 1
    else
        echo "Waiting for mysqld to initialize..."
    fi
done
echo "Unable to initialize mysqld!" >&2
exit 1
