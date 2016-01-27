#!/bin/bash
# This script will install the python-openstackclient package from the VIO OMS
# package repository. Requires sudo.


USAGE="Usage: $0 <OMS IP address>"

OMS_IP=$1

if [[ -z "$1" || "$1" == '-h' || "$1" == '--help' ]]; then
    echo "$USAGE"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

function cleanup {
    rm /etc/apt/sources.list.d/os_sources.list
}

trap cleanup EXIT

# Create temporary apt source pointing to OMS package repository
cat << EOF > /etc/apt/sources.list.d/os_sources.list
deb [arch=amd64] http://$OMS_IP/apt/viostack /
deb [arch=amd64] http://$OMS_IP/apt/viobaseos trusty/kilo main universe
deb [arch=amd64] http://$OMS_IP/apt/viopatch /
EOF

# Update apt cache using only the temporary apt source. Then install the
# python-openstackclient package, which will install all of the necessary
# OpenStack clients (e.g. nova, glance)
apt-get update -o Dir::Etc::sourcelist="/sources.list.d/os_sources.list"
apt-get install -y python-openstackclient
