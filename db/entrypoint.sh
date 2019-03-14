#!/bin/bash

SECRETS_DIR="${SECRETS_DIR:-/run/secrets}"
SECRETS_FILE=${SECRETS_DIR}/pdb.rc

case $1 in
    version)
        versions.sh docker-entrypoint-initdb.d/PEOPLE-prod.sql
        exit 0 ;;
    mysqld)
        : ;;
    *)
        echo "Unsupported action: $1" >&2
        exit 1 ;;
esac

if [ -f "${SECRETS_FILE}" ] ; then
    MYSQL_ROOT_PASSWORD=`sed -n -e 's/^PDB_ROOT_PASSWORD=\(.*\)/\1/p' ${SECRETS_FILE}`
    export MYSQL_ROOT_PASSWORD
fi
exec docker-entrypoint.sh "$@"
