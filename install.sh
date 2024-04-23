#!/bin/env bash

## Update and Upgrade Apt repositories 
## Update Disrobution Packages
## Remove Unneeded Dependancies
## clears out the local repository of retrieved package files

# sudo -s -- <<EOF
# apt-get update
# apt-get upgrade -y
# apt-get dist-upgrade -y
# apt-get autoremove -y
# apt-get autoclean -y
# EOF

## One liner to replace the above update code 
sudo bash -c 'for i in update {,dist-}upgrade auto{remove,clean}; do apt-get $i -y; done’

packages=$1

while read -r line ; do
    echo "$line"man apt-get | grep autoclean --context=5
done < $packages

