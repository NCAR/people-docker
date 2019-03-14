#!/bin/sh
# dumpinfo.sh dumpfile
-- Server version5.6.43-84.3-log

dump_mysqld=`head -6 $1 | sed -n 's/-- Server version\s*\(.*\)/\1p'`
dumpdate=`tail $1 | sed -n 's/-- Dump completed on \([-0-9]*\) \([0-9:]*\).*/\1T\2/p'`
mysqld=`mysqld --version | sed 's/.* Ver \([^ ]*\).*/\1'`
mysql=`mysql --version | sed 's/.* Ver \([^ ]*\).*/\1'`

cat <<EOF
dump_mysqld  ${dump_mysqld}
dump_date    ${dumpdate}
mysqld       ${mysqld}
mysql        ${mysql}
EOF

# mysqld --version
#mysqld  Ver 5.6.43 for Linux on x86_64 (MySQL Community Server (GPL))
# mysql --version
#mysql  Ver 14.14 Distrib 5.6.43, for Linux (x86_64) using  EditLine wrapper
