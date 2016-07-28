#!/bin/sh

IMG=

if [[ ! -z "$IMG" ]]; then
  DS_IMAGE=$IMG
fi

if [[ ! -z "$1" ]]; then
  DS_IMAGE=$1
fi

if [ -z "${DS_IMAGE}" ]; then
  echo "Usage: $(basename "$0") <IMAGE_NAME>"
  exit 1
fi

DS_USER="${USER}"
DS_UID="$(id -u)"
DS_GID="$(id -g)"

case "$OSTYPE" in
  darwin*)
    DS_SHELL=$(dscl . -read /Users/${USER} UserShell | cut -d' ' -f2) ;;
  linux*)
    DS_SHELL=$(getent passwd ${USER} | cut -d':' -f7) ;;
esac

pwd

docker run -e "DS_USER=${DS_USER}"   \
           -e "DS_UID=${DS_UID}"     \
           -e "DS_GID=${DS_GID}"     \
           -e "DS_SHELL=${DS_SHELL}" \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v ${HOME}:/home/${USER}  \
           -v `pwd`:/src             \
           -t -i                     \
           ${DS_IMAGE}
