#!/bin/bash

# A relatively simple script to setup your VM if not using the Vagrant stuff.

TOP_DIR=$(readlink -f $(dirname $0) )

set -o nounset
set -o errexit
set -o xtrace


# Must be root
if [[ $EUID -ne 0 ]]; then
    echo "Must be root to run this script"
    exit 1
fi

export LANG=en_US.utf8

echo "Install pip..."
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py

echo "Update apt-get database..."
apt-get update

echo "Install required packages..."
# Ansible needed packages
PACKAGES="python-dev libffi-dev libssl-dev"
PACKAGES="nfs-kernel-server ${PACKAGES}"
PACKAGES="git ${PACKAGES}"

apt-get install --assume-yes ${PACKAGES}

echo "Install ansible, at least 2.0 ..."
pip install ansible

echo "Create ansible hosts file to run ansible in the local VM..."
cd $TOP_DIR/ansible
echo "localhost              ansible_connection=local" > hosts

echo "Run ansible..."
ansible-playbook -vvv -i hosts playbook.yml

echo "You might want to make a snapshot of this VM for future use"
