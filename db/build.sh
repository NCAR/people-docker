#!/bin/sh
PROG=build.sh
DESC="Build and tag a PeopleDB docker image from a MySQL dump file"
USAGE1="$PROG [--registry=docker_registry] [--image=image_name] dumpfile"
USAGE2="$PROG -h|--help"
SCRIPTDIR=`cd \`dirname $0\`; pwd`

BUILD_DIR="${BUILD_DIR:-${SCRIPTDIR}}"
DOCKER_REGISTRY=
IMAGE="${IMAGE:-people-db}"
DUMPFILE="${DUMPFILE:-PEOPLE-prod.sql}"
HELP_TEXT="
NAME
    ${PROG} - ${DESC}

SYNOPSIS
    ${USAGE1}
    ${USAGE2}

DESRIPTION
"
USAGE="Usage:
    $USAGE1
    $USAGE1"

while [ ":$1" != ":" ] ; do
    case $1 in
        -h|--help)
            echo "${HELP_TEXT}"
            exit 0 ;;
        --registry=*)
            DOCKER_REGISTRY=`expr "$1" : '--registry=\(.*\)'`
            shift ;;
        --image=*)
            IMAGE=`expr "$1" : '--image=\(.*\)'`
            shift ;;
        -*)
            echo "${PROG}: unknown option: \"$1\"" >&2
            echo "${USAGE}" >&2
            exit 1 ;;
        *)
            DUMPFILE="$1"
            break ;;
    esac
done

if [ ":$DUMPFILE" = ":" ] ; then
    echo "$PROG: dumpfile argument is required" >&2
    echo "${USAGE}" >&2
    exit 1
fi
if [ ! -f "$DUMPFILE" ] ; then
    echo "$PROG: $DUMPFILE: no such file" >&2
    exit 1
fi
if [ ! -f ${BUILD_DIR}/Dockerfile ] ; then
    echo "${PROG}: expecting Dockerfile in $BUILD_DIR directory" >&2
    exit 1
fi
if [ ":${DOCKER_REGISTRY}" = ":" ] ; then
    IMAGE_PATH="${IMAGE}"
else
    IMAGE_PATH="${DOCKER_REGISTRY}/${IMAGE}"
fi

DUMPDATE=`${SCRIPTDIR}/versions.sh --dump_date "${DUMPFILE}"| sed -e 's/dump_date *//'`
DUMP_DATETIME_TAG=`echo "$}DUMPDATE}" | sed -e 's/[-:]//g'`
DUMP_DATE_TAG=`expr "${DUMP_DATETIME_TAG}" : '\([^T]*\)T.*'`

cp "${DUMPFILE}" ${SCRIPTDIR}/PEOPLE-prod.sql "${BUILD_DIR}" || exit 1

docker build -t "${IMAGE_PATH}:latest" \
             --build-arg DUMPDATE="${DUMPDATE}"
             --build-arg MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
             --build-arg MYSQL_PASSWORD=${MYSQL_PASSWORD} \
              ${BUILD_DIR}

docker tag "${IMAGE_PATH}:latest" "${IMAGE_PATH}:${DUMP_DATETIME_TAG}"
docker tag "${IMAGE_PATH}:latest" "${IMAGE_PATH}:${DUMP_DATE_TAG}"
