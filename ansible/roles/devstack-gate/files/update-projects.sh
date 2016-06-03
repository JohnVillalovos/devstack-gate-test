# This is used to do various updates after the /opt/stack/old and /opt/stack/new directories have been setup
# This file will be sourced in
#
# This is setup for stable/mitaka

errexit=$(set +o | grep errexit)
set -o errexit
xtrace=$(set +o | grep xtrace)
set -o xtrace

patch_repo() {
    local repo=${1:?repo not specified}
    local remote=${2:?remote not specified}
    local ref=${3:?ref not specified}


    pushd ${repo}
    flock -w 900 . sudo bash -c \
        "git fetch ${remote} ${ref} && git cherry-pick --keep-redundant-commits FETCH_HEAD || git reset"
    popd
}


patch_() {
    local number=${1:?number not specified}
    local epoch=${2:-both}

    local details=()
    # nothing to do if review returns 1
    details=($(review ${number})) || return 0
    local project=$(basename ${details[0]})
    local remote=${details[1]}
    local ref=${details[2]}
    local dir=/opt/stack
    local repos=()
    case ${epoch} in
        old)
            repos=(${dir}/old/${project});;
	new)
            repos=(${dir}/new/${project});;
        both)
            repos=(${dir}/old/${project} ${dir}/new/${project});;
	*)
            repos=(${dir})
    esac
    for repo in ${repos[@]}; do
        patch_repo ${repo} ${remote} ${ref}
    done
}

review() {
    # echo project url ref to cherry pick
    # return 1 if already merged
    local number=${1:?no number specified}
    local result=()

    result=($(http https://review.openstack.org/changes/${number}/revisions/current/review | tail -n+2 | jq -er 'if .status == "NEW" then ({project} + .revisions[.current_revision].fetch["anonymous http"])["project", "url","ref"] else false end')) || return ${?}
    echo ${result[@]}

}


# ***** grenade project patches  ****************************************************
echo "***: Open up firewall for ironic provisioning"
# https://review.openstack.org/#/c/315268/
(patch_ 315268)

echo "***: Enable PS4 for grenade.sh"
# https://review.openstack.org/#/c/318352/
(patch_ 318352)


echo "***: Load settings from plugins in upgrade-tempest"
# https://review.openstack.org/#/c/317993/
(patch_ 317993)

# ***** tempest project patches  ****************************************************
echo "****: Fetching the tempest smoke patch"
# https://review.openstack.org/#/c/315422/
(patch_ 315422)


# # ***** devstack-gate project patches  ****************************************************
# openstack-infra/devstack-gate: Allow to pass OS_TEST_TIMEOUT for grenade job
# https://review.openstack.org/#/c/316662/
(patch_ 316662)

# openstack-infra/devstack-gate: Allow to set Ironic provision timeout from the job
# https://review.openstack.org/#/c/315496/
(patch_ 315496)

echo "***: WIP: Add some debugging code (PS4 & xtrace)"
# https://review.openstack.org/#/c/318227/
(patch_ 318227 new)
details=($(review 318227)) && {
    (patch_repo /home/jenkins/workspace/testing/devstack-gate ${details[1]} ${details[2]})
}

# ***** devstack project patches  ****************************************************
echo "***: Export the 'short_source' function"
# https://review.openstack.org/#/c/313132/
(patch_ 313132 old)

echo "***: Fix ironic compute_driver name"
# https://review.openstack.org/#/c/318027/
(patch_ 318027 old)

# ***** nova project patches  ****************************************************
echo '***: Fix update inventory for multiple providers'
# https://review.openstack.org/#/c/316031/
(patch_ 316031)


# ***** ironic-python-agent project patches  ****************************************************
# .....


# ***** ironic project patches  ****************************************************
# start vsaienko/vdrok patches
echo '***: Gracefully degrade start_iscsi_target for Mitaka ramdisk'
# https://review.openstack.org/#/c/319183/
(patch_ 319183 new)

echo '***: Restart n-cpu after Ironic install'
# https://review.openstack.org/#/c/318479/
(patch_ 318479 new)

echo "***: Move all cleanups to cleanup_ironic"
# https://review.openstack.org/#/c/318660/
(patch_ 318660 new)

echo 'Keep backward compatibility for openstack port create'
# https://review.openstack.org/#/c/319232/
(patch_ 319232 new)

echo '***: Make sure create_ovs_taps creates unique taps'
# https://review.openstack.org/#/c/319101/
(patch_ 319101 new)

echo '***: Revert "Run smoke tests after upgrade"'
# https://review.openstack.org/#/c/319372/
(patch_ 319372 new)
##### end vsaienko/vdrok patches


echo "***: Fetching the Ironic disable cleaning patch"
# https://review.openstack.org/#/c/309115/
(patch_ 309115 old)

echo "***: Update resources subnet CIDR"
# https://review.openstack.org/#/c/317082/
(patch_ 317082 new)

echo "*** Allow Devstack on Xenial in Mitaka"
# https://review.openstack.org/#/c/324295/1
(patch_ 324295 old)


# *** ironic python client
# openstack/python-ironicclient: Catch RetriableConnectionFailures from KAuth and retry
# https://review.openstack.org/323851
# if this works, won't need to do extra reboots of nova compute during upgrade (so we'd undo the code that is doing the reboots)
(patch_ 323851 new)


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

