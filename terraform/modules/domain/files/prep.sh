 #!/bin/bash

 hostnamectl set-hostname $1
 /bin/rm -v /etc/ssh/ssh_host_*
 dpkg-reconfigure openssh-server
 rm /etc/machine-id
 systemd-machine-id-setup

 apt update
