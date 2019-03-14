#!/bin/bash
SECRETS_DIR="${SECRETS_DIR:-/run/secrets}"
SECRETS_FILE="${SECRETS_DIR}/pdb.rc"
MYSQL=${MYSQL:-/usr/bin/mysql}
MYSQL_DATABASE=${MYSQL_DATABASE:-people}
MYCNF=/tmp/mysql.cnf

touch ${MYCNF}
chmod 600 ${MYCNF}
if [ -f "${SECRETS_FILE}" ] ; then
    . "${SECRETS_FILE}" || exit 1
    cat >${MYCNF} <<EOF
[client]
user = root
password = ${PDB_ROOT_PASSWORD}
host = ${PDB_HOST}
port = ${PDB_PORT}
EOF
fi

${MYSQL} --defaults-extra-file=${MYCNF} "$@" ${MYSQL_DATABASE}
