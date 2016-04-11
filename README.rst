.. contents:: Table of Contents

devstack-gate-test
==================

Please create the directory /opt/git and have it owned by the user that will be
running Vagrant. It is highly recommended to setup a cache of files here.

I recommend if on Ubuntu 14.04 to get the latest version of Vagrant from
https://www.vagrantup.com/downloads.html and download the Debian 64-bit flavor.

Inside the created Virtual Machine a 'backdoor' user is created and is able
sudo to root.  The user's SSH public key is copied to the 'backdoor' and the
'jenkins' user.  This is because the puppet script will remove the ability to
SSH as root. This is a problem if you decide to use just the ansible portion to
run on an OpenStack VM, as you would not be able to login.


Pre-requisites
--------------

Pre-requisites needed for running devstack-gate (assuming Ubuntu 14.04):

1. Vagrant - latest version can be downloaded from
   www.vagrantup.com/downloads.html), Debian 64-bit flavor
2. VirtualBox - latest version. Can be done by running sudo apt-get install
   virtualbox. Once you have it installed you probably want to install guest
   additions in the guest OS. And you probably also want the extension pack
   which you can get from here: www.virtualbox.org/wiki/Downloads.


The two important scripts:

``ironic-grenade.sh`` - This file clones the devstack-gate into your workspace.
References the update-projects.sh in an export statement. It exports all local
modules grenade things, and runs baremetal tests.

``update-projects.sh`` - This file is used to do various updates after the
/opt/stack/old and /opt/stack/new are set up. Again, this file is referenced
and sourced into ironic-grenade.sh.


To run the tests:

1. SSH into the vm using vagrant.

	$ vagrant up

	$ vagrant ssh

2. Switch to the jenkins user, and run the ironic-grenade.sh script.

	$ sudo su - jenkins

	$ ./ironic-grenade.sh

Running takes about 30-40 mins unfortunately. After which you can see the logs
in /home/jenkins/workspace/testing/logs/. Specifically, grenade.sh.txt.gz.



Anytime major changes are made to files, the image for the VM box needs to be
recreated as follows:

Pull the latest changes. Create a package.box by doing:

	$ vagrant package

This will create a package.box in your current directory. You must now add this
box so that vagrant can find it and use it:

	$ vagrant box add --name devstack-gate package.box


After this you should have your directory called devstack-gate-test with
everything, and also a Vagrantfile.package file in it.

To avoid doing a rebuild every single time any minor changes are made, create a
new directory devstack-gate-packaged, copy the Vagrantfile.package and rename
it to Vagrantfile. In this file, update the name of the box to whatever you
named when you created add the box with the "vagrant box add" command. This way
you would only be dealing with two directories, devstack-gate
devstack-gate-packaged.


Git Cache
---------

In my /opt/git/ I have these packages::

    /opt/git/
    |-- openstack
    |   |-- automaton
    |   |-- ceilometer
    |   |-- ceilometermiddleware
    |   |-- cinder
    |   |-- cliff
    |   |-- debtcollector
    |   |-- dib-utils
    |   |-- diskimage-builder
    |   |-- django_openstack_auth
    |   |-- futurist
    |   |-- glance
    |   |-- glance_store
    |   |-- heat
    |   |-- heat-cfntools
    |   |-- heat-templates
    |   |-- horizon
    |   |-- ironic
    |   |-- ironic-lib
    |   |-- ironic-python-agent
    |   |-- keystone
    |   |-- keystoneauth
    |   |-- keystonemiddleware
    |   |-- manila
    |   |-- manila-ui
    |   |-- neutron
    |   |-- neutron-fwaas
    |   |-- neutron-lbaas
    |   |-- neutron-vpnaas
    |   |-- nova
    |   |-- octavia
    |   |-- os-apply-config
    |   |-- os-brick
    |   |-- os-cloud-config
    |   |-- os-collect-config
    |   |-- os-net-config
    |   |-- os-refresh-config
    |   |-- oslo.cache
    |   |-- oslo.concurrency
    |   |-- oslo.config
    |   |-- oslo.context
    |   |-- oslo.db
    |   |-- oslo.i18n
    |   |-- oslo.log
    |   |-- oslo.messaging
    |   |-- oslo.middleware
    |   |-- oslo.policy
    |   |-- oslo.reports
    |   |-- oslo.rootwrap
    |   |-- oslo.serialization
    |   |-- oslo.service
    |   |-- oslo.utils
    |   |-- oslo.versionedobjects
    |   |-- oslo.vmware
    |   |-- pycadf
    |   |-- python-ironicclient
    |   |-- requirements
    |   |-- sahara
    |   |-- sahara-dashboard
    |   |-- stevedore
    |   |-- swift
    |   |-- taskflow
    |   |-- tempest
    |   |-- tempest-lib
    |   |-- tooz
    |   |-- tripleo-heat-templates
    |   |-- tripleo-image-elements
    |   |-- tripleo-incubator
    |   |-- trove
    |   `-- zaqar
    |-- openstack-dev
    |   |-- devstack
    |   |-- devstack-WIP
    |   |-- grenade
    |   `-- pbr
    |-- openstack-infra
    |   |-- devstack-gate
    |   `-- tripleo-ci
