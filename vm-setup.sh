#!/bin/bash

# A relatively simple script to setup your VM if not using the Vagrant stuff.

TOP_DIR=$(readlink -f $(dirname $0) )

set -o nounset
set -o errexit


# Must be root, and not using 'sudo ./vm-setup.sh'
if [[ "${1:-}" != "--force" ]]; then
    if [[ $EUID -ne 0 ]] || [[ -n ${SUDO_COMMAND:-} ]]; then
        echo "Must be root to run this script"
        echo "Please don't use 'sudo ./vm-setup.sh' as things can go wrong :("
        echo ""
        echo "Recommend to do: sudo su -"
        exit 1
    fi
fi

set -o xtrace
export LANG=en_US.utf8

echo "Update apt-get database..."
apt-get update

# Ansible needed packages
PACKAGES="python-dev python3-dev libffi-dev libssl-dev"
PACKAGES="nfs-kernel-server ${PACKAGES}"
PACKAGES="git python python3 gcc ${PACKAGES}"

echo "Install required packages..."
apt-get install --assume-yes ${PACKAGES}

echo "Install pip..."
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
python3 get-pip.py

echo "Install ansible, at least 2.0 ..."
pip install ansible

echo "Create ansible hosts file to run ansible in the local VM..."
cd $TOP_DIR/ansible
echo "localhost              ansible_connection=local" > hosts

echo "Run ansible..."
ansible-playbook -vvv -i hosts playbook.yml

echo "You might want to make a snapshot of this VM for future use"
