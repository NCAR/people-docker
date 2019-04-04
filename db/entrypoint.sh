#!/bin/bash

SECRETS_DIR="${SECRETS_DIR:-/run/secrets}"
SECRETS_FILES="
 pdb.env"

case $1 in
    version)
        echo "dump_mysqld  ${DUMP_SERVER_VERSION}"
        echo "dump_date    ${DUMP_DATE}"
        echo "mysqld      " `mysqld --version | sed 's/.* Ver \([^ ]*\).*/\1/'`
        echo "mysql       " `mysql --version | sed 's/.* Ver \([^ ]*\).*/\1/'`
        exit 0 ;;
    mysqld)
        : ;;
    *)
        echo "Unsupported action: $1" >&2
        exit 1 ;;
esac

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
