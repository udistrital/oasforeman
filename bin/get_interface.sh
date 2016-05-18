#!/bin/bash

set -eu

while getopts ":i:" opt; do
  case $opt in
    i)
      ip_addr="$OPTARG"
      ;;
  esac
done

interfaces="$(facter --json interfaces | jq -r '.interfaces|split(",")|.[]|"ipaddress_"+.')"

facter --json $interfaces | jq --arg ip "$ip_addr" -r 'to_entries|.[]|select(.value == $ip)|.key|split("_")[1]'
