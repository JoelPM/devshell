#!/bin/sh

#set -x

SDKS=(
  'elixir:1.3.2'
  'elixir:1.2.6'
  'erlang:19.0.1'
  'erlang:18.3.4.1'
  'erlang:17.5.6.9'
  'golang:1.5.4'
  'golang:1.6.3'
  'golang:1.7rc3'
  )

for SDK in ${SDKS[@]}; do
  IMG="devshell-${SDK}"
  echo "Building ${IMG}"
  sed "s~<SDK>~${SDK}~" Dockerfile > "Dockerfile.${IMG}"
  docker build -t "joelpm/${IMG}" . -f "Dockerfile.${IMG}"
  if [ $? -eq 0 ]; then
    docker push "joelpm/${IMG}"
    rm "Dockerfile.${IMG}"
    echo "Built $IMG"
  fi
done
