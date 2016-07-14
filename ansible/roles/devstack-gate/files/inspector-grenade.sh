#!/bin/bash

set -o xtrace
set -o errexit

# short_source prints out the current location of the caller in a way
# that strips redundant directories. This is useful for PS4 usage.
function short_source {
    saveIFS=$IFS
    IFS=" "
    called=($(caller 0))
    IFS=$saveIFS
    file=${called[2]}
    printf "%-40s " "$file:${called[1]}:${called[0]}"
}
# PS4 is exported to child shells and uses the 'short_source' function, so
# export it so child shells have access to the 'short_source' function also.
export -f short_source
export PS4='+ $(short_source):   '

TOPDIR=$(cd $(dirname $0) && pwd)
source $TOPDIR/patch_.sh

export LANG=en_US.utf8
export REPO_URL=https://git.openstack.org
export ZUUL_URL=/home/jenkins/cache-workspace
mkdir -p $ZUUL_URL
export ZUUL_REF=HEAD
export WORKSPACE=/home/jenkins/workspace/testing
mkdir -p $WORKSPACE

export ZUUL_PROJECT=openstack/ironic-inspector
export ZUUL_BRANCH=master

export ZUUL_REF=$(review 327667 | cut -d\  -f3,3 ||:)

# git clone $REPO_URL/$ZUUL_PROJECT $ZUUL_URL/$ZUUL_PROJECT \
#     && cd $ZUUL_URL/$ZUUL_PROJECT \
#     && git checkout remotes/origin/$ZUUL_BRANCH

ARGS_RSYNC="-rlptDH"
if [ -d /opt/git/pip-cache/ ]
then
    for user in jenkins root
    do
        eval user_dir=~${user}
        echo Copying pip cache from /opt/git/pip-cache/ to ${user_dir}/.cache/pip/
        sudo mkdir -p ${user_dir}/.cache/pip/
        sudo rsync ${ARGS_RSYNC} --exclude=selfcheck.json /opt/git/pip-cache/ ${user_dir}/.cache/pip/
        sudo chown -R $user:$user ${user_dir}/.cache/pip/
    done
fi

cd $WORKSPACE
[ -d devstack-gate ] || git clone --depth 1 $REPO_URL/openstack-infra/devstack-gate

# # Cherry pick our patch: Send DEVSTACK_GATE_TEMPEST_REGEX to grenade jobs
# (cd devstack-gate; git fetch https://review.openstack.org/openstack-infra/devstack-gate refs/changes/44/241044/3 && git cherry-pick FETCH_HEAD)

export DEVSTACK_GATE_SETTINGS="/home/jenkins/update-projects.sh"


# At this point you're ready to set the same environment variables and run the
# same commands/scripts as used in the desired job. The definitions for these
# are found in the openstack-infra/project-config project under the
# jenkins/jobs directory in a file named devstack-gate.yaml. It will probably
# look something like:

# # Let's use KVM
# export DEVSTACK_GATE_LIBVIRT_TYPE=kvm


# From openstack-infra/project-config/jenkins/jobs/devstack-gate.yaml
# ***************** Grenade stuff ************************
# Local mods
export PROJECTS="openstack/ironic $PROJECTS"
export PROJECTS="openstack/ironic-lib $PROJECTS"
export PROJECTS="openstack/ironic-python-agent $PROJECTS"
export PROJECTS="openstack/python-ironicclient $PROJECTS"
export PROJECTS="openstack/ironic-inspector $PROJECTS"
export PROJECTS="openstack/python-ironic-inspector-client $PROJECTS"
export PROJECTS="openstack-dev/grenade $PROJECTS"
export PYTHONUNBUFFERED=true
export GIT_BASE=http://git.openstack.org/
#export GIT_BASE=http://github.com/
export DEVSTACK_GATE_TIMEOUT=120
export DEVSTACK_GATE_GRENADE=pullup
export DEVSTACK_GATE_IRONIC=1
export DEVSTACK_GATE_NEUTRON=1
export DEVSTACK_GATE_VIRT_DRIVER=ironic
export DEVSTACK_GATE_OS_TEST_TIMEOUT=2400
export DEVSTACK_GATE_TEMPEST_BAREMETAL_BUILD_TIMEOUT=1200
export TARGET_RUN_SMOKE=true


# export DEVSTACK_GATE_TEMPEST=1
# export DEVSTACK_GATE_TEMPEST_ALL_PLUGINS="1"


# BEGIN: Since stable/mitaka ********************************************************
export GRENADE_PLUGINRC+=$'\n'"enable_grenade_plugin ironic http://git.openstack.org/openstack/ironic"
export GRENADE_PLUGINRC+=$'\n'"enable_grenade_plugin ironic-inspector http://git.openstack.org/openstack/ironic-inspector $ZUUL_REF"

# END: Since stable/mitaka **********************************************************

#export TEMPEST_CONCURRENCY=2
export TEMPEST_CONCURRENCY=1



#------------------------ RAMDISK START -------------------------------------
# Use TinyIPA
export IRONIC_RAMDISK_TYPE=tinyipa
export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_VM_SPECS_RAM=384"
export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_VM_COUNT=5"
# Bug in stable/mitaka. Make sure it is true to use tinyipa, though that is the
# default.
export IRONIC_BUILD_DEPLOY_RAMDISK=true


# For CoreOS
#export IRONIC_RAMDISK_TYPE=coreos
# The CoreOS IPA ramdisk needs at least 1GB of RAM to run
#export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_VM_SPECS_RAM=1024"
#export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_VM_COUNT=2"


export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_RAMDISK_TYPE=$IRONIC_RAMDISK_TYPE"
#------------------------ RAMDISK END -------------------------------------


# Need to explicitly set IRONIC_IPXE_ENABLED value as default value changed
# between Mitaka and Newton. Need to have consistent value.
export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_IPXE_ENABLED=True"
export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_DEPLOY_DRIVER_ISCSI_WITH_IPA=True"
export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_INSPECTOR_RAMDISK_ELEMENT=ironic-agent"
export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_INSPECTOR_MANAGE_FIREWALL=True"


# export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_HW_NODE_DISK=2"
# export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_VM_SPECS_DISK=2"

# JLV set GIT_BASE since those devstack people refuse to change to a sensible
# default and insist on using 'git://' :(  Yay for insecurity!
export DEVSTACK_LOCAL_CONFIG+=$'\n'"GIT_BASE=$GIT_BASE"



# export BRANCH_OVERRIDE={branch-override}
export BRANCH_OVERRIDE=default
if [ "$BRANCH_OVERRIDE" != "default" ] ; then
    export OVERRIDE_ZUUL_BRANCH=$BRANCH_OVERRIDE
fi
cp devstack-gate/devstack-vm-gate-wrap.sh ./safe-devstack-vm-gate-wrap.sh

# So the safe-devstack-vm-gate-wrap.sh is likely going to fail. So don't error
# exit
set +o errexit
# Pipe in /dev/null as had strange issues occur if didn't
./safe-devstack-vm-gate-wrap.sh </dev/null

# (jlvillal) I tried to pipe it and the script would just hang at the end :(
# ./safe-devstack-vm-gate-wrap.sh </dev/null 2>&1 | tee console.txt
# cp ~/console.txt /opt/stack/logs/console.txt

cd /opt/stack/logs/ && ~/bin/uncompress-gz-files.py > /dev/null

if [ -d /opt/git/pip-cache/ ]
then
    set +o errexit
    for user in jenkins root stack
    do
        eval user_dir=~${user}
        echo Copying pip cache files from ${user_dir}/.cache/pip/ to /opt/git/pip-cache/
        sudo rsync ${ARGS_RSYNC} --exclude=selfcheck.json ${user_dir}/.cache/pip/ /opt/git/pip-cache/
    done
fi
