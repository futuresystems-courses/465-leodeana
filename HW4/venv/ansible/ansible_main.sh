module load openstack
source ~/.cloudmesh/clouds/india/juno/openrc.sh

set -x

KEY="host_india contact_badi_AT_iu_edu"
NMACHINES=2
NAME_PREFIX=$USER-test

FLAVOR=m1.small
IMAGE=futuresystems/ubuntu-14.04
DELAY=10s

SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

###################################################################### util functions

get-int-ip() {
    local name=$1
    nova show $name | grep 'int-net network' | awk '{print $5}'
}

boot-vm() {
    local name=$1
    nova boot --flavor $FLAVOR --image $IMAGE --key_name "$KEY" $name
    sleep $DELAY

    while true; do
	IP=$(get-int-ip $name)
	test ! -z $IP && break
	sleep 20s # not ideal, but needs to be >15s to avoid flooding API calls
    done
    echo $IP

    while ! nc -zv $IP 22; do
	sleep $DELAY
    done
}

###################################################################### boot

NAMES=
ADDRESSES=
for i in `seq $NMACHINES`; do
    name=$NAME_PREFIX-$i
    boot-vm $name
    NAMES="$NAMES $name"
    ip=$(get-int-ip $name)
    ADDRESSES="$ADDRESSES $ip"
done

###################################################################### run
# forward ssh agent
eval $(ssh-agent -s)
ssh-add


#### install ansible in a local venv
virtualenv venv
source venv/bin/activate
pip install ansible

#### generate the inventory
cat >inventory.txt<<EOF
[all]
$(echo $ADDRESSES | tr ' ' '\n')
EOF

#### run the playbook
ansible-playbook -i inventory.txt -c ssh apache.yaml

#### check that apache is running
egrep '[[:digit:]]' inventory.txt | while read addr; do
    nc -zv $addr 80 || echo "[$addr] Nothing listening on port 80"
    curl $addr >/dev/null 2>&1 || echo "[$addr] webserver not running"
done

# don't leave agent hanging around :security:
ssh-agent -k
