#!/bin/sh
# versions.sh [--dump_mysqld|dump_date|mysqld|mysql] dumpfile
PROG=versions.sh

VARS="dump_mysqld dump_date mysqld mysql"
DUMPFILE=
while [ ":$1" != ":" ] ; do
    case $1 in
      --dump_mysqld|--dump_date|--mysqld|--mysql)
        VARS=`expr ":$1" : ':--\(.*\)'`
        shift ;;
      *)
        DUMPFILE="$1"
        shift ;;
    esac
done
if [ ":$DUMPFILE" = ":" ] ; then
    echo "$PROG: dumpfile argument is required" >&2
    exit 1
fi
for var in ${VARS} ; do
    case $var in
        dump_mysqld)
            echo "dump_mysqld " `head -6 ${DUMPFILE} | sed -n 's/-- Server version[ 	]*\(.*\)/\1/p'` ;;
        dump_date)
            echo "dump_date   " `tail ${DUMPFILE} | sed -n 's/-- Dump completed on \([-0-9]*\) \([0-9:]*\).*/\1T\2/p'` ;;
        mysqld)
            echo "mysqld      " `mysqld --version | sed 's/.* Ver \([^ ]*\).*/\1/'` ;;
        mysql)
            echo "mysql       " `mysql --version | sed 's/.* Ver \([^ ]*\).*/\1/'` ;;
    esac
done

