#!/bin/bash

if [ -z "$PS1" ]
then
  set -eu
fi

dev_null=${OAS_DEV_NULL:-/dev/null}
dev_stdout=${OAS_DEV_STDERR:-/dev/stdout}
dev_stderr=${OAS_DEV_STDERR:-/dev/stderr}
rake=${OAS_RAKE:-bundle exec rake}

if ! type ruby &> $dev_null
then
  echo "ruby no instalado"
  echo "centos"
  echo "sudo yum install -y ruby"
  echo "macosx"
  echo "rbenv install"
  exit 1
fi

if ! type bundle &> $dev_null
then
  echo "bundler.io no encontrado, tratando de instalar" > $dev_stderr
  gem install bundler
fi

if ! bundle check &> $dev_null
then
  exe/setup
fi

if ! $rake --version &> $dev_null
then
  echo "rake no instalado"
  exit 2
fi

$rake "$@"
