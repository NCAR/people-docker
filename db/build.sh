#!/bin/sh
PROG=build.sh
DESC="Build and tag a PeopleDB docker image from a MySQL dump file"
USAGE1="$PROG [--image=image_name] dumpfile"
USAGE2="$PROG -h|--help"
IMAGE=people-db
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
SCRIPTDIR=`cd \`dirname $0\`; pwd`

while [ ":$1" != ":" ] ; do
    case $1 in
        -h|--help)
            echo "${HELP_TEXT}"
            exit 0 ;;
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
if [ ! -f ${SCRIPTDIR}/Dockerfile ] ; then
    echo "${PROG}: expecting Dockerfile in script directory" >&2
    exit 1
fi

DUMPDATE=`${SCRIPTDIR}/versions.sh --dump_date "${DUMPFILE}"| sed -e 's/dump_date *//'`
TAG=`echo "${DUMPDATE}" | sed -e 's/[-:]//g'`

cp "${DUMPFILE}" ${SCRIPTDIR}/PEOPLE-prod.sql || exit 1

docker build -t "${IMAGE}:${TAG}" -t "${IMAGE}:latest" --build-arg DUMPDATE="${DUMPDATE}" ${SCRIPTDIR}