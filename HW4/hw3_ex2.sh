#!/usr/bin/env bash

module load openstack
source ~/.cloudmesh/clouds/india/juno/openrc.sh

set -x

STACK_NAME=heat-lab-ex2-solution
INSTANCE_NAME=wordpress_instance
KEY='host_india contact_badi_AT_iu_edu'

SCRIPT=heat_ex2.typescript

DELAY=15s
LONG_DELAY=60s

###################################################################### util functions
get-vm-id() {
    local name_pattern=$1
    nova list | grep $name_pattern | awk '{print $2}'
}

get-ext-ip() {
    local id=$1
    nova show $id | grep 'int-net network' | awk '{print $6}'
}

###################################################################### typescript

#script $SCRIPT

###################################################################### boot
heat stack-create \
    -u https://raw.githubusercontent.com/cloudmesh/cloudmesh/dev2.0/heat-templates/fedora-21/wordpress.yaml \
    -P key_name="$KEY" \
    $STACK_NAME

###################################################################### get ip address
ADDRESS=

while true; do
    id=$(get-vm-id $STACK_NAME-$INSTANCE_NAME)
    test ! -z $id && break
    sleep $DELAY
done

while true; do
    ip=$(get-ext-ip $id)
    test ! -z $ip && break
    sleep $DELAY
done

ADDRESS="$ip"


###################################################################### wait for services to start

# wait for the webserver to start listening on port 80

echo "Waiting for provisioning to finish"
echo "This may take several minutes, please be patient"

while ! nc -zv $ADDRESS 80; do
    sleep $LONG_DELAY
done


###################################################################### check the ports

nmap $ADDRESS


###################################################################### get the index page

curl -L $ADDRESS/wordpress >index.html
