#!/bin/sh
DOCKER_IMAGE=$1
DOCKER_RUN="docker run --rm -i -v $(pwd):/local -w /local ${DOCKER_IMAGE}"

CMD="tsc --types /usr/local/lib/node_modules/@types/node hello_world.ts 1>&2 && \
    node hello_world.js && \
    rm -f hello_world.js"
RESULT="$(${DOCKER_RUN} sh -c "${CMD}")"
echo "${RESULT}"
if [ "${RESULT}" = "Hello, world!" ]
then
    echo "PASSED"
else
    echo "FAILED"
    exit 1
fi
