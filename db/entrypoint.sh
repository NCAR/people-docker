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
    . "${SECRETS_FILE}"
    export PDB_LOGIN PDB_PASSWORD PDB_HOST PDB_PORT
fi
echo "${PDB_LOGIN}" >/tmp/mysql_user.txt
echo "${PDB_PASSWORD}" | sha256sum >/tmp/mysql_password.sha256
cmp /mysql_user.txt /tmp/mysql_user.txt
if [ $? != 0 ] ; then
    echo "\$PDB_LOGIN does not match database user in image" >&2
    exit 1
fi
cmp /mysql_password.sha256 /tmp/mysql_password.sha256
if [ $? != 0 ] ; then
    echo "\$PDB_PASSWORD does not match database user password in image" >&2
    exit 1
fi

if [ ! -f /var/lib/mysql/ibdata1 ] ; then
    echo "Loading database..."
    cd /
    tar xzf /db.tgz var/lib/mysql
    tar xzf /db.tgz var/run/mysqld
fi
echo "Starting database server..."
exec gosu mysql "$@"
