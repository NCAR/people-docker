#!/bin/bash
SECRETS_DIR="${SECRETS_DIR:-/run/secrets}"
SECRETS_FILE="${SECRETS_DIR}/pdb.rc"
MYSQL=${MYSQL:-/usr/bin/mysql}
MYSQL_DATABASE=${MYSQL_DATABASE:-people}

if [ -f "${SECRETS_FILE}" ] ; then
    . "${SECRETS_FILE}" || exit 1
fi
if expr "=${MYSQL_ROOT_PASSWORD}=${PDB_HOST}=${PDB_PORT}=" : '=..*=..*=..*=' >/dev/null ; then
    MYCNF=/tmp/root_mysql.cnf
    PDB_LOGIN=root
    PDB_PASSWORD=${MYSQL_ROOT_PASSWORD}
elif expr "=${PDB_LOGIN}=${PDB_PASSWORD}=${PDB_HOST}=${PDB_PORT}=" : '=..*=..*=..*=..*=' >/dev/null ; then
    MYCNF=/tmp/pdb_mysql.cnf
else
    echo "Unable to connect to mysqld: missing parameters" >&2
    exit 1
fi
touch ${MYCNF}
chmod 600 ${MYCNF}
cat >${MYCNF} <<EOF
[client]
user = ${PDB_LOGIN}
password = ${PDB_PASSWORD}
host = ${PDB_HOST}
port = ${PDB_PORT}
EOF

echo ${MYSQL} --defaults-extra-file=${MYCNF} "$@" ${MYSQL_DATABASE}y
${MYSQL} --defaults-extra-file=${MYCNF} "$@" ${MYSQL_DATABASE}
