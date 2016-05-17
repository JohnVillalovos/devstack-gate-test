# This is used to do various updates after the /opt/stack/old and /opt/stack/new directories have been setup
# This file will be sourced in
#
# This is setup for stable/mitaka

errexit=$(set +o | grep errexit)
set -o errexit
xtrace=$(set +o | grep xtrace)
set -o xtrace

# ***** grenade project patches  ****************************************************
echo "****: Fetching the grenade patch"
# https://review.openstack.org/#/c/241018/ Support TEMPEST_REGEX environment variable
(cd /opt/stack/new/grenade; git fetch https://review.openstack.org/openstack-dev/grenade refs/changes/18/241018/4 && git cherry-pick FETCH_HEAD)
(cd /opt/stack/old/grenade; git fetch https://review.openstack.org/openstack-dev/grenade refs/changes/18/241018/4 && git cherry-pick FETCH_HEAD)

echo "****: Fetching debug grenade patch..."
# https://review.openstack.org/#/c/314334/ WIP: Debug
(cd /opt/stack/new/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/34/314334/1 && git cherry-pick FETCH_HEAD)
(cd /opt/stack/old/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/34/314334/1 && git cherry-pick FETCH_HEAD)

echo "***: Open up firewall for ironic provisioning"
# https://review.openstack.org/#/c/315268/
(cd /opt/stack/new/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/68/315268/1 && git cherry-pick FETCH_HEAD)
(cd /opt/stack/old/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/68/315268/1 && git cherry-pick FETCH_HEAD)

echo "***: Skip cinder test if c-api not enabled"
# https://review.openstack.org/#/c/317076/
(cd /opt/stack/new/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/76/317076/6 && git cherry-pick FETCH_HEAD || git reset)
(cd /opt/stack/old/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/76/317076/6 && git cherry-pick FETCH_HEAD || git reset)


# ***** devstack-gate project patches  ****************************************************
echo "***: Fetching the devstack-gate TEMPEST_REGEX patch"
# https://review.openstack.org/#/c/241044/ Send DEVSTACK_GATE_TEMPEST_REGEX to grenade jobs
(cd /opt/stack/new/devstack-gate; git fetch https://review.openstack.org/openstack-infra/devstack-gate refs/changes/44/241044/3 && git cherry-pick FETCH_HEAD)

echo "***: Fetching: Archive Ironic VM nodes console logs for 'old' patch"
# https://review.openstack.org/#/c/290171/ Archive Ironic VM nodes console logs for 'old'
(cd /opt/stack/new/devstack-gate; git fetch https://review.openstack.org/openstack-infra/devstack-gate refs/changes/71/290171/1 && git cherry-pick FETCH_HEAD)
(cd /home/jenkins/workspace/testing/devstack-gate; git fetch https://review.openstack.org/openstack-infra/devstack-gate refs/changes/71/290171/1 && git cherry-pick FETCH_HEAD)


# ***** devstack project patches  ****************************************************
echo "***: Export the 'short_source' function"
# https://review.openstack.org/#/c/313132/
(cd /opt/stack/old/devstack; git fetch https://git.openstack.org/openstack-dev/devstack refs/changes/32/313132/6 && git cherry-pick FETCH_HEAD)


# ***** ironic-python-agent project patches  ****************************************************
# .....


# ***** ironic project patches  ****************************************************
echo "***: Fetching the Ironic disable cleaning patch"
# https://review.openstack.org/#/c/309115/
(cd /opt/stack/old/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/15/309115/1 && git cherry-pick FETCH_HEAD)

echo "***: Enable download of tinyipa prebuilt image"
# https://review.openstack.org/#/c/314933/
(cd /opt/stack/old/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/33/314933/3 && git cherry-pick FETCH_HEAD || git reset)

echo "***: Setup for using the Grenade 'early_create' phase"
# https://review.openstack.org/#/c/316234/
(cd /opt/stack/old/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/34/316234/7 && git cherry-pick FETCH_HEAD || git reset)
(cd /opt/stack/new/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/34/316234/7 && git cherry-pick FETCH_HEAD || git reset)

echo "***: Update resources subnet CIDR"
# https://review.openstack.org/#/c/317082/
(cd /opt/stack/old/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/82/317082/2 && git cherry-pick FETCH_HEAD)
(cd /opt/stack/new/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/82/317082/2 && git cherry-pick FETCH_HEAD)

echo "***: Fix shutdown.sh & upgrade.sh for grenade"
# https://review.openstack.org/317139
(cd /opt/stack/old/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/39/317139/3 && git cherry-pick FETCH_HEAD || git reset)
(cd /opt/stack/new/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/39/317139/3 && git cherry-pick FETCH_HEAD || git reset)


# Prep the pip cache for the stack user, which is owned by the 'jenkins' user at this point
if [ -d /opt/git/pip-cache/ ]
then
    ARGS_RSYNC="-rlptDH"
    sudo -u jenkins mkdir -p ~stack/.cache/pip/
    sudo -u jenkins rsync ${ARGS_RSYNC} --exclude=selfcheck.json /opt/git/pip-cache/ ~stack/.cache/pip/
fi

# old stable/liberty patches
# echo "***: Fetching the proxy server patch for stable/liberty"
# # https://review.openstack.org/283375 Add support for proxy servers during image build
# (cd /opt/stack/old/ironic-python-agent; git fetch https://review.openstack.org/openstack/ironic-python-agent refs/changes/75/283375/1 && git cherry-pick FETCH_HEAD)

# echo "***: Keep the console logs for all boots"
# # https://review.openstack.org/#/c/293748/ Keep the console logs for all boots
# (cd /opt/stack/old/devstack; git fetch https://review.openstack.org/openstack-dev/devstack refs/changes/48/293748/2 && git cherry-pick FETCH_HEAD)

$xtrace
$errexit
