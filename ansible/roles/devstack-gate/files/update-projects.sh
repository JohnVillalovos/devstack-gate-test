# This is used to do various updates after the /opt/stack/old and /opt/stack/new directories have been setup
# This file will be sourced in
#
# This is setup for stable/mitaka

errexit=$(set +o | grep errexit)
set -o errexit
xtrace=$(set +o | grep xtrace)
set -o xtrace

# ***** grenade project patches  ****************************************************
echo "***: Open up firewall for ironic provisioning"
# https://review.openstack.org/#/c/315268/
(cd /opt/stack/new/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/68/315268/1 && git cherry-pick FETCH_HEAD || git reset)
(cd /opt/stack/old/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/68/315268/1 && git cherry-pick FETCH_HEAD || git reset)

echo "***: Enable PS4 for grenade.sh"
# https://review.openstack.org/#/c/318352/
(cd /opt/stack/new/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/52/318352/1 && git cherry-pick FETCH_HEAD || git reset)
(cd /opt/stack/old/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/52/318352/1 && git cherry-pick FETCH_HEAD || git reset)

echo "***: Load settings from plugins in upgrade-tempest"
# https://review.openstack.org/#/c/317993/
(cd /opt/stack/new/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/93/317993/1 && git cherry-pick FETCH_HEAD || git reset)
(cd /opt/stack/old/grenade; git fetch https://git.openstack.org/openstack-dev/grenade refs/changes/93/317993/1 && git cherry-pick FETCH_HEAD || git reset)


# ***** tempest project patches  ****************************************************
echo "****: Fetching the tempest smoke patch"
# https://review.openstack.org/#/c/315422/
(cd /opt/stack/new/tempest; git fetch https://git.openstack.org/openstack/tempest refs/changes/22/315422/9 && git cherry-pick FETCH_HEAD || git reset)
(cd /opt/stack/old/tempest; git fetch https://git.openstack.org/openstack/tempest refs/changes/22/315422/9 && git cherry-pick FETCH_HEAD || git reset)


# # ***** devstack-gate project patches  ****************************************************
echo "***: WIP: Add some debugging code (PS4 & xtrace)"
# https://review.openstack.org/#/c/318227/
(cd /opt/stack/new/devstack-gate; git fetch https://git.openstack.org/openstack-infra/devstack-gate refs/changes/27/318227/1 && git cherry-pick FETCH_HEAD)
(cd /home/jenkins/workspace/testing/devstack-gate; git fetch https://git.openstack.org/openstack-infra/devstack-gate refs/changes/27/318227/1 && git cherry-pick FETCH_HEAD)


# ***** devstack project patches  ****************************************************
echo "***: Export the 'short_source' function"
# https://review.openstack.org/#/c/313132/
(cd /opt/stack/old/devstack; git fetch https://git.openstack.org/openstack-dev/devstack refs/changes/32/313132/6 && git cherry-pick FETCH_HEAD)

echo "***: Fix ironic compute_driver name"
# https://review.openstack.org/#/c/318027/
(cd /opt/stack/old/devstack; git fetch https://git.openstack.org/openstack-dev/devstack refs/changes/27/318027/1 && git cherry-pick FETCH_HEAD || git reset)


# ***** nova project patches  ****************************************************
echo '***: Fix update inventory for multiple providers'
# https://review.openstack.org/#/c/316031/
(cd /opt/stack/old/nova; git fetch https://git.openstack.org/openstack/nova refs/changes/31/316031/5 && git cherry-pick FETCH_HEAD)
(cd /opt/stack/new/nova; git fetch https://git.openstack.org/openstack/nova refs/changes/31/316031/5 && git cherry-pick FETCH_HEAD)


# ***** ironic-python-agent project patches  ****************************************************
# .....


# ***** ironic project patches  ****************************************************
# start vsaienko/vdrok patches
echo '***: Gracefully degrade start_iscsi_target for Mitaka ramdisk'
# https://review.openstack.org/#/c/319183/
(cd /opt/stack/new/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/83/319183/5 && git cherry-pick FETCH_HEAD)

echo '***: Restart n-cpu after Ironic install'
# https://review.openstack.org/#/c/318479/
(cd /opt/stack/new/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/79/318479/8 && git cherry-pick FETCH_HEAD)

echo "***: Move all cleanups to cleanup_ironic"
# https://review.openstack.org/#/c/318660/
(cd /opt/stack/new/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/60/318660/6 && git cherry-pick FETCH_HEAD)

echo 'Keep backward compatibility for openstack port create'
# https://review.openstack.org/#/c/319232/
(cd /opt/stack/new/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/32/319232/3 && git cherry-pick FETCH_HEAD)

echo '***: Make sure create_ovs_taps creates unique taps'
# https://review.openstack.org/#/c/319101/
(cd /opt/stack/new/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/01/319101/4 && git cherry-pick FETCH_HEAD)

echo '***: Revert "Run smoke tests after upgrade"'
# https://review.openstack.org/#/c/319372/
(cd /opt/stack/new/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/72/319372/1 && git cherry-pick FETCH_HEAD)
##### end vsaienko/vdrok patches


echo "***: Fetching the Ironic disable cleaning patch"
# https://review.openstack.org/#/c/309115/
(cd /opt/stack/old/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/15/309115/1 && git cherry-pick FETCH_HEAD)

echo "***: Update resources subnet CIDR"
# https://review.openstack.org/#/c/317082/
(cd /opt/stack/new/ironic; git fetch https://git.openstack.org/openstack/ironic refs/changes/82/317082/2 && git cherry-pick FETCH_HEAD)




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
