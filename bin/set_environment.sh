#!/bin/bash

set -eu

ENVTOOL_FILENAME=${ENVTOOL_FILENAME:-/etc/environment}

get_env_value() {
  source "$ENVTOOL_FILENAME"
  echo "${!environment_name}"
}

while getopts ":n:v:" opt; do
  case $opt in
    n)
      environment_name="$OPTARG"
      ;;
    v)
      environment_value="$OPTARG"
      ;;
  esac
done

is_set="false"
if egrep "^\s*${environment_name}=" "$ENVTOOL_FILENAME" > /dev/null
then
  is_set="true"
fi

if [ "$is_set" = "true" ]
then
  if [ -z "${environment_value}"  ]
  then
    sed -i.bak -E "/(^[[:space:]]*${environment_name})=/d" "$ENVTOOL_FILENAME"
  elif [ "$(get_env_value)" != "${environment_value}" ]
  then
    sed -i.bak -E "s|(^[[:space:]]*${environment_name})=.*|\\1=${environment_value}|" "$ENVTOOL_FILENAME"
  fi
elif [ ! -z "${environment_value}" ]
then
  echo "${environment_name}=${environment_value}" >> "$ENVTOOL_FILENAME"
fi
