#!/bin/bash

set -e

R10K="/opt/puppetlabs/puppet/bin/r10k"
#FLAGS="-v debug"
FLAGS=""
PUPPET_UID=997 # 997=puppet

if [ $EUID -ne $PUPPET_UID ]; then
  (>&2 echo $0 must be run as the puppet user)
  exit 1
fi

# Args are repository, ref, deleted
if [ $# -ne 3 ]; then # Missing args, run full deploy
  ${R10K} deploy environment --puppetfile ${FLAGS}
elif [[ "${1}" =~ ^module-(.+)$ ]]; then # Module repo, deploy module
  module=${BASH_REMATCH[1]}
  echo "Deploying module ${module}"
  ${R10K} deploy module ${module} ${FLAGS}
else
  if [[ "${1}" =~ ^(.+)_control$ ]]; then # Control repo, add prefix to environment
    prefix="${BASH_REMATCH[1]}_"
  fi
  if [[ "${2}" =~ ^refs/heads/(.+)$ ]]; then
    branch=${BASH_REMATCH[1]}
  fi
  if [ "${3}" = "true" ]; then
    echo "Purging environment ${prefix}${branch}"
    ${R10K} deploy environment ${FLAGS}
  else
    echo "Deploying environment ${prefix}${branch}"
    ${R10K} deploy environment ${prefix}${branch} --puppetfile ${FLAGS}
  fi
fi

if [[ -f /etc/puppetlabs/r10k/gitsync/master/r10k.yaml ]]; then
  if ! diff -q /etc/puppetlabs/r10k/r10k.yaml /etc/puppetlabs/r10k/gitsync/master/r10k.yaml; then
    cp /etc/puppetlabs/r10k/gitsync/master/r10k.yaml /etc/puppetlabs/r10k/r10k.yaml
    echo "r10k.yaml change detected. Running full r10k deploy..."
    ${R10K} deploy environment --puppetfile ${FLAGS}
  fi
fi

if [[ -f /etc/puppetlabs/r10k/gitsync/master/envlink.yaml ]]; then
  cp /etc/puppetlabs/r10k/gitsync/master/envlink.yaml /etc/puppetlabs/envlink/envlink.yaml
fi

cd ${HOME}/envlink
/opt/puppetlabs/puppet/bin/ruby exe/envlink
