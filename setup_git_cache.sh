#!/bin/bash

if [ ! -d /opt/git ]; then
        sudo mkdir -p /opt/git
fi
sudo chown $USER /opt/git
cd /opt/git

git_root=https://git.openstack.org
repo_list=$(cat <<'END_REPOS'
openstack/automaton
openstack/ceilometer
openstack/ceilometermiddleware
openstack/cinder
openstack/cliff
openstack/debtcollector
openstack-dev
openstack-dev/devstack
openstack-dev/devstack-WIP
openstack-dev/grenade
openstack-dev/pbr
openstack/dib-utils
openstack/diskimage-builder
openstack/django_openstack_auth
openstack/futurist
openstack/glance
openstack/glance_store
openstack/heat
openstack/heat-cfntools
openstack/heat-templates
openstack/horizon
openstack-infra
openstack-infra/devstack-gate
openstack-infra/tripleo-ci
openstack/ironic
openstack/ironic-lib
openstack/ironic-python-agent
openstack/keystone
openstack/keystoneauth
openstack/keystonemiddleware
openstack/manila
openstack/manila-ui
openstack/neutron
openstack/neutron-fwaas
openstack/neutron-lbaas
openstack/neutron-vpnaas
openstack/nova
openstack/octavia
openstack/os-apply-config
openstack/os-brick
openstack/os-cloud-config
openstack/os-collect-config
openstack/oslo.cache
openstack/oslo.concurrency
openstack/oslo.config
openstack/oslo.context
openstack/oslo.db
openstack/oslo.i18n
openstack/oslo.log
openstack/oslo.messaging
openstack/oslo.middleware
openstack/oslo.policy
openstack/oslo.reports
openstack/oslo.rootwrap
openstack/oslo.serialization
openstack/oslo.service
openstack/oslo.utils
openstack/oslo.versionedobjects
openstack/oslo.vmware
openstack/os-net-config
openstack/os-refresh-config
openstack/pycadf
openstack/python-ironicclient
openstack/requirements
openstack/sahara
openstack/sahara-dashboard
openstack/stevedore
openstack/swift
openstack/taskflow
openstack/tempest
openstack/tempest-lib
openstack/tooz
openstack/tripleo-heat-templates
openstack/tripleo-image-elements
openstack/tripleo-incubator
openstack/trove
openstack/zaqar
END_REPOS
)

for repo in $repo_list
do
        git clone $git_root/$repo $repo &
done
wait
