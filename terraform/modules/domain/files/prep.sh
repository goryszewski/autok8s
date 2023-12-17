 #!/bin/bash

 hostnamectl set-hostname  $1
 /bin/rm -v /etc/ssh/ssh_host_*
 dpkg-reconfigure openssh-server
 rm /etc/machine-id
 systemd-machine-id-setup

update-ca-certificates

# DOTO add proxy

#  cat <<EOF | sudo tee /etc/environment
# http_proxy="http://192.168.100.10:3128"
# https_proxy="http://192.168.100.10:3128"
# no_proxy="localhost,127.0.0.1,10.0.0.0/8"
# NO_PROXY="localhost,127.0.0.1,10.0.0.0/8"
# EOF
