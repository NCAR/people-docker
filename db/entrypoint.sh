#!/bin/bash

case $1 in
    version)
        echo "dump_mysqld:    ${DUMP_SERVER_VERSION}"
        echo "dump_date:      ${DUMPDATE}"
        echo "mysqld:        " `mysqld --version | sed 's/.* Ver \([^ ]*\).*/\1/'`
        echo "mysql:         " `mysql --version | sed 's/.* Ver \([^ ]*\).*/\1/'`
        exit 0 ;;
    configvars)
        echo "# people-db:"
        cat /configvars.env
        exit 0 ;;
    mysqld)
        : ;;
    *)
        echo "Unsupported action: $1" >&2
        exit 1 ;;
esac

rm -rf /tmp/envvars_cache.rc
. /load-configvars.rc

read mysqluser </mysql_user.txt
echo "${PDB_PASSWORD}" | sha256sum >/tmp/mysql_password.sha256

if [ ":$mysqluser" != ":${PDB_LOGIN}" ] ; then
    echo "WARNING: \${PDB_LOGIN} (\"${PDB_LOGIN}\") does not match database user in image (\"${mysqluser}\")" >&2
fi
cmp /mysql_password.sha256 /tmp/mysql_password.sha256
if [ $? != 0 ] ; then
    echo "WARNING: \${PDB_PASSWORD} does not match database user password in image" >&2
fi

if [ ! -f /var/lib/mysql/ibdata1 ] ; then
    echo "Loading database..."
    cd /
    tar xzf /db.tgz var/lib/mysql
    tar xzf /db.tgz var/run/mysqld
fi
echo "Starting database server..."
exec gosu mysql "$@"
