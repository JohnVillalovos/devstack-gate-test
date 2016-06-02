# This is used to do various updates after the /opt/stack/old and /opt/stack/new directories have been setup
# This file will be sourced in
#
# This is setup for stable/mitaka

errexit=$(set +o | grep errexit)
set -o errexit
xtrace=$(set +o | grep xtrace)
set -o xtrace

rem_line_func_file() {
    local frame=0
    while caller ${frame} ; do
        ((frame++))
    done > /dev/null 2>&1

    caller $[frame - 1]
}

rem_init() {
    # magic will clone self removing lines that need no patching
    local called=($(rem_line_func_file))
    cp -f ${called[2]} ${called[2]}~
}

rem_term() {
    local called=($(rem_line_func_file))
    mv ${called[2]}~ ${called[2]}
}


rem_line() {
    # rem line where this call was initialized from
    local called=($(rem_line_func_file))
    local file=${DIRSTACK[${#DIRSTACK[@]} - 1]}/${called[2]}
    local line=${called[0]}
    flock -w 900 ${file}~ \
    ed ${file}~ <<__EOF_ED
${line},${line}s/^/#~L~/
w
q
__EOF_ED
}

# magic

rem_init


patch_repo() {
    local repo=${1:?repo not specified}
    local remote=${2:?remote not specified}
    local ref=${3:?ref not specified}
    local hard=${4}

    pushd ${repo}
    flock -w 900 . sudo bash -c \
        "git fetch ${remote} ${ref} && git cherry-pick --keep-redundant-commits FETCH_HEAD || { git reset ; exit 1 ; }" || {
            [ -n ${hard} ] && return $?
            # magically remove caller line
	    rem_line
        }
    popd
}


patch_() {
    local remote=${1:?remote not specified}
    local ref=${2:?ref not specified}
    local epoch=${3:-both}
    local hard=${4}

    local project=$(basename $remote)
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
        patch_repo ${repo} ${remote} ${ref} ${hard}
    done
}

patch_infra() {
    local project_name=${1:?project name not specified}
    local ref=${2:?ref not specified}
    local epoch=${3:-both}
    local hard=${4}

    patch_ https://git.openstack.org/openstack-infra/${project_name} ${ref} ${epoch} ${hard}
}

patch_dev() {
    local project_name=${1:?project name not specified}
    local ref=${2:?ref not specified}
    local epoch=${3:-both}
    local hard=${4}

    patch_ https://git.openstack.org/openstack-dev/${project_name} ${ref} ${epoch} ${hard}
}

patch_proj() {
    local project_name=${1:?project name not specified}
    local ref=${2:?ref not specified}
    local epoch=${3:-both}
    local hard=${4}

    patch_ https://git.openstack.org/openstack/${project_name} ${ref} ${epoch} ${hard}
}


# ***** grenade project patches  ****************************************************
echo "***: Open up firewall for ironic provisioning"
# https://review.openstack.org/#/c/315268/
#~L~(patch_dev grenade refs/changes/68/315268/1) &

echo "***: Enable PS4 for grenade.sh"
# https://review.openstack.org/#/c/318352/
(patch_dev grenade refs/changes/52/318352/1) &

echo "***: Load settings from plugins in upgrade-tempest"
# https://review.openstack.org/#/c/317993/
(patch_dev grenade refs/changes/93/317993/1) &


# ***** tempest project patches  ****************************************************
echo "****: Fetching the tempest smoke patch"
# https://review.openstack.org/#/c/315422/
#~L~#~L~(patch_proj tempest refs/changes/22/315422/9) &


# # ***** devstack-gate project patches  ****************************************************
echo "***: WIP: Add some debugging code (PS4 & xtrace)"
# https://review.openstack.org/#/c/318227/
(patch_infra devstack-gate refs/changes/27/318227/1 new) &
(patch_repo /home/jenkins/workspace/testing/devstack-gate https://git.openstack.org/openstack-infra/devstack-gate refs/changes/27/318227/1) &


# ***** devstack project patches  ****************************************************
echo "***: Export the 'short_source' function"
# https://review.openstack.org/#/c/313132/
(patch_dev devstack refs/changes/32/313132/6 old) &

echo "***: Fix ironic compute_driver name"
# https://review.openstack.org/#/c/318027/
(patch_dev devstack refs/changes/27/318027/1 old) &


# ***** nova project patches  ****************************************************
echo '***: Fix update inventory for multiple providers'
# https://review.openstack.org/#/c/316031/
(patch_proj nova refs/changes/31/316031/5) &


# ***** ironic-python-agent project patches  ****************************************************
# .....


# ***** ironic project patches  ****************************************************
# start vsaienko/vdrok patches
echo '***: Gracefully degrade start_iscsi_target for Mitaka ramdisk'
# https://review.openstack.org/#/c/319183/
(patch_proj ironic refs/changes/83/319183/5 new) &

echo '***: Restart n-cpu after Ironic install'
# https://review.openstack.org/#/c/318479/
(patch_proj ironic refs/changes/79/318479/8 new) &

echo "***: Move all cleanups to cleanup_ironic"
# https://review.openstack.org/#/c/318660/
(patch_proj ironic refs/changes/60/318660/6 new) &

echo 'Keep backward compatibility for openstack port create'
# https://review.openstack.org/#/c/319232/
(patch_proj ironic refs/changes/32/319232/3 new) &

echo '***: Make sure create_ovs_taps creates unique taps'
# https://review.openstack.org/#/c/319101/
(patch_proj ironic refs/changes/01/319101/4 new) &

echo '***: Revert "Run smoke tests after upgrade"'
# https://review.openstack.org/#/c/319372/
(patch_proj ironic refs/changes/72/319372/1 new) &
##### end vsaienko/vdrok patches


echo "***: Fetching the Ironic disable cleaning patch"
# https://review.openstack.org/#/c/309115/
(patch_proj ironic refs/changes/15/309115/1 old) &

echo "***: Update resources subnet CIDR"
# https://review.openstack.org/#/c/317082/
(patch_proj ironic refs/changes/82/317082/2 new) &

echo "*** Allow Devstack on Xenial in Mitaka"
# https://review.openstack.org/#/c/324295/1
(patch_dev devstack refs/changes/95/324295/1 old) &

wait

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

# magic
rem_term
