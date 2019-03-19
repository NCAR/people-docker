#!/bin/bash
MYSQL_SH=/usr/local/bin/mysql.sh
if [ ":$1" != ":-v" ] ; then
    exec 2>/dev/null
fi
out=`echo "show tables" | ${MYSQL_SH} | grep '^username_type'`
case ${out} in
    username_type)
        exit 0 ;;
    *)
        exit 1 ;;
esac

