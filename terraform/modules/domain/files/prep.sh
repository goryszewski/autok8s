 #!/bin/bash

 hostnamectl set-hostname  $1
 /bin/rm -v /etc/ssh/ssh_host_*
 dpkg-reconfigure openssh-server
 rm /etc/machine-id
 systemd-machine-id-setup

update-ca-certificates

# DOTO add proxy

#  cat <<EOF | sudo tee /etc/profile.d/proxy.sh
# export http_proxy="http://192.168.100.10:3128"
# export https_proxy="http://192.168.100.10:3128"
# EOF
