#!/bin/bash
SECRETS_DIR="${SECRETS_DIR:-/run/secrets}"
SECRETS_FILES="${SECRETS_DIR}/pdb.env"
MYSQL=${MYSQL:-/usr/bin/mysql}

# Set environment variables for secrets from files if files are there. Do not allow interpolation.
TMPFILE=/tmp/secrets
trap "rm -f ${TMPFILE} ; exit 1" 1 2 13 15
for file in ${SECRETS_FILES} ; do
    rcfile="${SECRETS_DIR}/${file}"
    if [ -f "${rcfile}" ] ; then
        echo "Reading ${rcfile}"
        cat "${rcfile}"
    fi
done | grep '^ *[a-zA-Z][a-zA-Z0-9_]*=.*' > ${TMPFILE}
while read line ; do
    var=`expr "${line}" : '\([^=]*\)=.*'`
    val=`expr "${line}" : '[^=]*=\(.*\)'`
    eval "${var}=\"${val}\""
    export $var
done <$TMPFILE
rm -f ${TMPFILE}

MYSQL_DATABASE=${MYSQL_DATABASE:-people}
MYSQL_TCP_PORT=${PDB_PORT:-3306}
MYSQL_HOST=${PDB_HOST:-db}
MYSQL_USER=${PDB_LOGIN:-people}
MYSQL_PASSWORD=${PDB_PASSWORD}
export MYSQL_DATABASE MYSQL_TCP_PORT MYSQL_HOST MYSQL_USER
if [ ":${PDB_PASSWORD}" != ":" ] ; then
    export MYSQL_PASSWORD
fi

${MYSQL} "--user=${MYSQL_USER}" "--password=${MYSQL_PASSWORD}" "$@" ${MYSQL_DATABASE}
