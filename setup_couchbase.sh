#!/bin/bash

# Not possible to run docker container in travis...
# https://docs.travis-ci.com/user/database-setup/#starting-services => Couchbase not yet available

set -e

export CB_VERSION=5.1.1
export CB_RELEASE_URL=https://packages.couchbase.com/releases
export CB_PACKAGE=couchbase-server-community_5.1.1-ubuntu14.04_amd64.deb

# Community Edition requires that all nodes provision all services or data service only
export SERVICES="kv,n1ql,index,fts"

export USERNAME=admin
export PASSWORD=password

export MEMORY_QUOTA=256
export INDEX_MEMORY_QUOTA=256
export FTS_MEMORY_QUOTA=256


# Check if couchbase server is up
check_db() {
  curl --silent http://127.0.0.1:8091/pools > /dev/null
  echo $?
}

echo "Prepare Couchbase dependencies"
sudo apt-get update 
sudo apt-get install -yq libssl1.0.0 runit wget python-httplib2 chrpath tzdata lsof lshw sysstat net-tools numactl

echo "Downloading couchbase"
wget -q -N $CB_RELEASE_URL/$CB_VERSION/$CB_PACKAGE
sudo dpkg -i ./$CB_PACKAGE && rm -f ./$CB_PACKAGE

echo "Wait for couchbase startup"

# Wait until it's ready
until [[ $(check_db) = 0 ]]; do
  >&2 numbered_echo "Waiting for Couchbase Server to be available"
  sleep 1
done

echo "# Couchbase Server Online"
echo "# Starting setup process"

numbered_echo "Setting up memory"
  curl --silent "http://127.0.0.1:8091/pools/default" \
    -d memoryQuota=${MEMORY_QUOTA} \
    -d indexMemoryQuota=${INDEX_MEMORY_QUOTA} \
    -d ftsMemoryQuota=${FTS_MEMORY_QUOTA}

  numbered_echo "Setting up services"
  curl --silent "http://127.0.0.1:8091/node/controller/setupServices" \
    -d services="${SERVICES}"

  numbered_echo "Setting up user credentials"
  curl --silent "http://127.0.0.1:8091/settings/web" \
    -d port=8091 \
    -d username=${USERNAME} \
    -d password=${PASSWORD} > /dev/null
    
echo "Couchbase running successfully" 