#!/usr/bin/env bash

DOCKER_IMAGE=$(docker inspect --format='{{.Config.Image}}' $HOSTNAME)
if [ ! $? -eq 0 ]; then
  DOCKER_IMAGE="<DOCKER_IMAGE>"
fi

# If the first argument is "script" then we output the script that
# makes invoking this image easier.
#if [ "$1" = "script" ]; then
if [ ! -t 0 ]; then
  if [ "${DOCKER_IMAGE}" == "<DOCKER_IMAGE>" ]; then
    cat /devshell/devshell.sh
  else
    sed "s~IMG=~IMG='${DOCKER_IMAGE}'~g" /devshell/devshell.sh
  fi
  exit 0;
fi

usage() {
  cat <<EOM
USAGE:
docker run -e "DS_USER=<USERNAME>"        \\
           -e "DS_UID=<UID>"              \\
           -e "DS_GID=<GID>"              \\
           -e "DS_SHELL=<SHELL_NAME>"     \\
           -v /var/run/docker.sock:/var/run/docker.sock \\
           -v <HOME_DIR>:/home/<USERNAME> \\
           -v \`pwd\`:/src                  \\
           -t -i                          \\
           ${DOCKER_IMAGE}

Where:
  <USERNAME>   is your user name
  <UID>        is your user ID
  <GID>        is your group ID
  <SHELL_NAME> is your default shell

To output a script that will automatically run this command, do:
  docker run ${DOCKER_IMAGE} script
EOM
}

if [[ -z $DS_USER ]]; then
  echo "The environment variables DS_USER was not set."
  usage
  exit 1;
fi

if [[ -z $DS_UID ]]; then
  echo "The environment variables DS_UID was not set."
  usage
  exit 1;
fi

if [[ -z $DS_GID ]]; then
  echo "The environment variables DS_GID was not set."
  usage
  exit 1;
fi

if [[ -z $DS_SHELL ]]; then
  echo "The environment variables DS_SHELL was not set."
  usage
  exit 1;
fi

case "$DS_SHELL" in
  *zsh)
    DS_SHELL=/bin/zsh ;;
  *)
    DS_SHELL=/bin/bash ;;
esac

echo "Creating $DS_USER ($DS_UID:$DS_GID) - $DS_SHELL in container"

# make the user group
/usr/sbin/groupadd -g $DS_GID $DS_USER || true

# make my user
# -l is required: https://github.com/docker/docker/issues/5419
/usr/sbin/useradd -l -d /home/$DS_USER -s $DS_SHELL -c "$DS_USER" -g $DS_GID $DS_USER -u $DS_UID || true

# enable sudo
cat > /etc/sudoers <<< "$DS_USER ALL=(ALL) NOPASSWD: ALL"

su - $DS_USER
