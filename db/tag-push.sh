#!/bin/sh
PROG=tag-push.sh
DESC="Tag and push a docker image built by build.sh"
USAGE1="$PROG [image_name]"
USAGE2="$PROG -h|--help"
IMAGE_DEFAULT=people-db

HELP_TEXT="
NAME
    ${PROG} - ${DESC}

SYNOPSIS
    ${USAGE1}
    ${USAGE2}

DESCRIPTION
    Tag and push a People database image. The pushed image includes the
    \"latest\" tag, as well as the date and date-plus-time of the dump used
    to create the image; the date tag is of the form \"%Y%m%d\" while the
    date-plus-time tag is of the form \"%Y%m%dT%H%M%S\".  The image is assumed
    to include the label \"dumpdate\", with the dump date in the form
    \"%Y-%m-%dT%H:%M:%S\" (ISO 8601). See \"build.sh\".

    Note that this script assumes \"docker login\" has been called to log in
    to the target registry.

    The following arguments are supported:

    -h|--help
        Display help text.

    image_name
        If given, the name of the image without a registry component.

ENVIRONMENT
    IMAGE
        (Optional) The default image name, if no image_name argument is
        provided. Default is \"${IMAGE_DEFAULT}\".

    DOCKER_REGISTRY
        (Optional) The Docker registry to push to; default is Docker Hub.
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

DUMPDATE=`docker inspect --format='{{.Config.Labels.dumpdate}}' "${IMAGE}"`
DUMP_DATETIME_TAG=`echo "${DUMPDATE}" | sed -e 's/[-:]//g'`
DUMP_DATE_TAG=`expr "${DUMP_DATETIME_TAG}" : '\([^T]*\)T.*'`

if [ ":${DOCKER_REGISTRY}" = ":" ] ; then
    IMAGE_PATH="${IMAGE}"
else
    IMAGE_PATH="${DOCKER_REGISTRY}/${IMAGE}"
fi

set -ex

docker tag "${IMAGE}:latest" "${IMAGE_PATH}:latest"
docker tag "${IMAGE}:latest" "${IMAGE_PATH}:${DUMP_DATETIME_TAG}"
docker tag "${IMAGE}:latest" "${IMAGE_PATH}:${DUMP_DATE_TAG}"

docker push "${IMAGE_PATH}"
