#!/bin/bash
# Script to automate vagrant installation


set -x

# Sets the base directory to the directory where the script is at.
dirname $0
BASE_DIR=$(dirname $0)


set -o errexit

# Go to the BASE_DIR, then execute all vagrant commands.
cd $BASE_DIR
time vagrant destroy -f
time vagrant up
rm -f package.box
time vagrant package
time vagrant box add --force --name devstack-gate package.box
time vagrant destroy -f
mkdir -p ~/devstack-gate-test-packaged
cp $BASE_DIR/Vagrantfile.packaged ~/devstack-gate-test-packaged/Vagrantfile
cd ~/devstack-gate-test-packaged/
time vagrant destroy -f
time vagrant up
cd ~/devstack-gate-test-packaged/






