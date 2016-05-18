#!/bin/bash

set -eu

awk '$1=="nameserver"{print $2;exit}' /etc/resolv.conf
