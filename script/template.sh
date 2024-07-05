#!/bin/bash
virsh start debian12 || echo 0

IP=$(virsh domifaddr debian12 | grep ipv4 |  awk '{print $4}'| cut -d'/' -f1 )
ansible-playbook ./test.yaml -i $IP, --tags TEMPLATE

sleep 5

virsh destroy debian12
