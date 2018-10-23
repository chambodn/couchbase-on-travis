#!/bin/bash

# Not possible to run docker container in travis...
# https://docs.travis-ci.com/user/database-setup/#starting-services => Couchbase not yet available

# set -e

# export CB_VERSION=5.1.1
# export CB_RELEASE_URL=https://packages.couchbase.com/releases
# export CB_PACKAGE=couchbase-server-community_5.1.1-ubuntu16.04_amd64.deb
# export CB_SHA256=b8d15af64710c61f8a98218c632becb400feec8a99a593f8e76aa3320fa58bbb

# echo "Prepare Couchbase dependencies"

# curl -O http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-4-amd64.deb
# sudo dpkg -i couchbase-release-1.0-4-amd64.deb

# sudo apt-get update 
# sudo apt-get install -yq libssl1.0.0 

# sudo apt install ./couchbase-server.deb


# Not possible to run docker container in travis...
# https://docs.travis-ci.com/user/database-setup/#starting-services => Couchbase not yet available
 set -e
 export CB_VERSION=5.1.1
export CB_RELEASE_URL=https://packages.couchbase.com/releases
export CB_PACKAGE=couchbase-server-community_5.1.1-ubuntu14.04_amd64.deb
 echo "Prepare Couchbase dependencies"
sudo apt-get update 
sudo apt-get install -yq libssl1.0.0 runit wget python-httplib2 chrpath tzdata lsof lshw sysstat net-tools numactl
 echo "Downloading couchbase"
wget -q -N $CB_RELEASE_URL/$CB_VERSION/$CB_PACKAGE
sudo dpkg -i ./$CB_PACKAGE && rm -f ./$CB_PACKAGE
 echo "Wait for couchbase startup"
sleep 10
 echo "Create [ admin ] user"

# Community Edition requires that all nodes provision all services or data service only
sudo /opt/couchbase/bin/couchbase-cli cluster-init \
      --cluster-username=admin \
      --cluster-password=password \
      --cluster-ramsize=2048 

echo "Couchbase running successfully" 