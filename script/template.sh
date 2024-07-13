#!/bin/bash
# virsh start debian12 || echo 0

IP=""

while true;
do
    IP=$(virsh domifaddr debian12 | grep ipv4 |  awk '{print $4}'| cut -d'/' -f1)
    echo $IP
    if [ $IP != "" ]
    then
        break
    fi
    sleep 1
    echo "sleep"
done
echo $IP
ansible-playbook ./test.yaml -i $IP, --tags TEMPLATE


# virsh destroy debian12
