#!/bin/sh

if [ -z "$TMP_COOKIE" ] || [ -z "$TMP_KEY" ] || [ -z "$DOCKER_CMD" ] || [ -z "$DOCKER_IMAGE" ]
then
    echo "error: missing environment variables" >&2
    exit 1
fi

set -e

# block signals to avoid a race condition if the script is killed just after
# the container is created
trap "echo 'SIGINT  (ignored)'" INT
trap "echo 'SIGTERM (ignored)'" TERM

# run the container
ctr=$(
    $DOCKER_CMD run -d \
    -p 55555:22 \
    --privileged \
    -v "$PWD/$TMP_KEY.pub:/home/docker/.ssh/authorized_keys:ro" \
    -v "$PWD/$TMP_COOKIE:/home/docker/.pulse-cookie" \
    -v ~/.Skype:/home/docker/.Skype \
    -v ~/Downloads:/home/docker/Downloads \
    "$DOCKER_IMAGE"
)

# cleanup handler called on exit
# -> stop and remove the container
cleanup()
{
    set +e
    $DOCKER_CMD stop "$ctr" >/dev/null
    $DOCKER_CMD rm   "$ctr" >/dev/null
}

trap cleanup EXIT
trap "echo SIGINT  ; exit" INT
trap "echo SIGTERM ; exit" TERM

# wait a few seconds to ensure that the container is ready
sleep 5

# run skype via ssh
ssh -X -a -i "$TMP_KEY" -R 64713:127.0.0.1:4713 -l docker -p 55555 127.0.0.1 skype

