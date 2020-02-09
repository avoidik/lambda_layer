#!/usr/bin/env bash

MACHINE_NAME="lambda-dep"

DEPS_LIST=("docker-machine" "docker" "terraform")
for item in "${DEPS_LIST[@]}"; do
  if ! command -v "$item" &> /dev/null ; then
    echo "Error: required command '$item' was not found" >&2
    exit 1
  fi
done

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -k|--keep) KEEP_IT="Y";;
    *) echo "Unknown parameter passed: $1" >&2; exit 1;;
  esac
  shift
done

# prepare dep layer

IS_STOP="$(docker-machine ls --filter name="${MACHINE_NAME}" --filter state=Stopped -q)"
if [[ -n "${IS_STOP}" ]]; then
  docker-machine rm -f "${MACHINE_NAME}"
fi

IS_RUN="$(docker-machine ls --filter name="${MACHINE_NAME}" --filter state=Running -q)"
if [[ -z "${IS_RUN}" ]]; then
  docker-machine create "${MACHINE_NAME}"
fi

eval "$(docker-machine env "${MACHINE_NAME}")"

if [ -d lambda/dep/python ]; then
  rm -rf lambda/dep/python
fi

mkdir -p lambda/dep/python

if [ -d lambda/pkg ]; then
  rm -rf lambda/pkg
fi

mkdir -p lambda/pkg

export MSYS2_ARG_CONV_EXCL='/work'

docker run \
  --rm \
  -w /work \
  -v /$(pwd)/lambda:/work \
  lambci/lambda:build-python3.6 \
  pip3 install -r requirements.txt --no-deps -t dep/python

if [[ "${KEEP_IT}" != "Y" ]]; then
  eval "$(docker-machine env -u)"
  docker-machine rm -f "${MACHINE_NAME}"
fi
