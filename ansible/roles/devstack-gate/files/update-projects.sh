# This is used to do various updates after the /opt/stack/old and /opt/stack/new directories have been setup
# This file will be sourced in

errexit=$(set +o | grep errexit)
set -o errexit
xtrace=$(set +o | grep xtrace)
set -o xtrace

echo "****: Fetching the grenade patch"
# https://review.openstack.org/#/c/241018/ Support TEMPEST_REGEX environment variable
(cd /opt/stack/new/grenade; git fetch https://review.openstack.org/openstack-dev/grenade refs/changes/18/241018/4 && git cherry-pick FETCH_HEAD)
(cd /opt/stack/old/grenade; git fetch https://review.openstack.org/openstack-dev/grenade refs/changes/18/241018/4 && git cherry-pick FETCH_HEAD)

echo "***: Debug openstack client failure"
# https://review.openstack.org/#/c/284442/ WIP: Fail devstack if some variables are not set
(cd /opt/stack/old/devstack; git fetch https://review.openstack.org/openstack-dev/devstack refs/changes/42/284442/1 && git cherry-pick FETCH_HEAD)

echo "***: Fetching the proxy server patch for stable/liberty"
# https://review.openstack.org/283375 Add support for proxy servers during image build
(cd /opt/stack/old/ironic-python-agent; git fetch https://review.openstack.org/openstack/ironic-python-agent refs/changes/75/283375/1 && git cherry-pick FETCH_HEAD)

echo "***: Fetching the devstack-gate TEMPEST_REGEX patch"
# https://review.openstack.org/#/c/241044/ Send DEVSTACK_GATE_TEMPEST_REGEX to grenade jobs
(cd /opt/stack/new/devstack-gate; git fetch https://review.openstack.org/openstack-infra/devstack-gate refs/changes/44/241044/3 && git cherry-pick FETCH_HEAD)

# Prep the pip cache for the stack user, which is owned by the 'jenkins' user at this point
if [ -d /opt/git/pip-cache/ ]
then
    ARGS_RSYNC="-rlptDH"
    sudo -u jenkins mkdir -p ~stack/.cache/pip/
    sudo -u jenkins rsync ${ARGS_RSYNC} --exclude=selfcheck.json /opt/git/pip-cache/ ~stack/.cache/pip/
fi

$xtrace
$errexit
