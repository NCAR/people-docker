#!/bin/sh
PROG=build.sh
DESC="Build and tag a PeopleDB docker image from a MySQL dump file"
USAGE1="$PROG [image_name]"
USAGE2="$PROG -h|--help"
SCRIPTDIR=`cd \`dirname $0\`; pwd`

REQUIRED_ENVVARS="MYSQL_ROOT_PASSWORD MYSQL_PASSWORD"
IMAGE_DEFAULT=people-db

HELP_TEXT="
NAME
    ${PROG} - ${DESC}

SYNOPSIS
    ${USAGE1}
    ${USAGE2}

DESCRIPTION
    Build a Docker image for a MySQL server initialized with data from a
    backup, which is read from standard input. The image includes the label
    \"dumpdate\", with a value in the form \"%Y-%m-%dT%H:%M:%S\" (ISO 8601),
    and the label \"dump_server_version\", with the version number of the MySQL
    server that produced the dump. The directory containing this script is
    assumed to contain a Dockerfile and the build context.

    The following arguments are supported:

    -h|--help
        Display help text.

    image_name
        If given, the name of the image without a registry component.

ENVIRONMENT
    IMAGE
        (Optional) The default image name, if no image_name argument is
        provided. Default is \"${IMAGE_DEFAULT}\".

    MYSQL_ROOT_PASSWORD
        (Required) The password to assign to the \"root\" MySQL account

    MYSQL_PASSWORD
        (Required) The password to assign to the \"people\" MySQL account
"
case $1 in
    -h|--help)
        echo "${HELP_TEXT}"
        exit 0 ;;
    -*)
        echo "${PROG}: unknown option: $1" >*2
        exit 1 ;;
    '')
        IMAGE="${IMAGE_DEFAULT}" ;;
    *)
        IMAGE="$1" ;;
esac

BUILD_DIR="${BUILD_DIR:-${SCRIPTDIR}}"

if [ ! -f ${BUILD_DIR}/Dockerfile ] ; then
    echo "${PROG}: expecting Dockerfile in $BUILD_DIR directory" >&2
    exit 1
fi
finally=:
for var in ${REQUIRED_ENVVARS} ; do
    eval val="\"\$${var}\""
    if [ ":${val}" = ":" ] ; then
        echo "${PROG}: environment variable ${var} is required" >&2
        finally="exit 1"
    fi
done
eval $finally

echo "Reading MySQL dump from standard input..." >&2

trap "rm -f ${BUILD_DIR}/PEOPLEDB.sql ; exit 1" 1 2 13 15
cat >"${BUILD_DIR}/PEOPLEDB.sql" || exit 1

DUMP_SERVER_VERSION=`head -6 "${BUILD_DIR}/PEOPLEDB.sql" | sed -n 's/-- Server version[ 	]*\(.*\)/\1/p'`
DUMPDATE=`tail -3 "${BUILD_DIR}/PEOPLEDB.sql" | sed -n 's/-- Dump completed on \([-0-9]*\) \([0-9:]*\).*/\1T\2/p'`
if [ ":${DUMPDATE}" = ":" ] ; then
    echo "${PROG}: standard input did not have a complete dump" >&2
    exit 1
fi
DUMP_DATETIME_TAG=`echo "${DUMPDATE}" | sed -e 's/[-:]//g'`
DUMP_DATE_TAG=`expr "${DUMP_DATETIME_TAG}" : '\([^T]*\)T.*'`

set -e

echo Running \
docker build -t "${IMAGE}:latest" \
             --build-arg DUMPDATE="${DUMPDATE}" \
             --build-arg DUMP_SERVER_VERSION="${DUMP_SERVER_VERSION}" \
             --build-arg MYSQL_ROOT_PASSWORD=### \
             --build-arg MYSQL_PASSWORD=### \
              ${BUILD_DIR} ...

docker build -t "${IMAGE}:latest" \
             --build-arg DUMPDATE="${DUMPDATE}" \
             --build-arg DUMP_SERVER_VERSION="${DUMP_SERVER_VERSION}" \
             --build-arg MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
             --build-arg MYSQL_PASSWORD=${MYSQL_PASSWORD} \
              ${BUILD_DIR}

rm -f ${BUILD_DIR}/PEOPLEDB.sql