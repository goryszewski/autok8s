#!/bin/bash

# $1 - IP
# $2 - DNS

echo "LOCAL - keygen"
ssh-keygen -R $1
ssh-keygen -R $2
