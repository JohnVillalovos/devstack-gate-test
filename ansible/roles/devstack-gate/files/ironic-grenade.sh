#!/bin/bash

set -o xtrace
set -o errexit

export REPO_URL=https://git.openstack.org
export ZUUL_URL=/home/jenkins/cache-workspace
mkdir -p $ZUUL_URL
export ZUUL_REF=HEAD
export WORKSPACE=/home/jenkins/workspace/testing
mkdir -p $WORKSPACE

export ZUUL_PROJECT=openstack/ironic
export ZUUL_BRANCH=master

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

cd $WORKSPACE \
    && git clone --depth 1 $REPO_URL/openstack-infra/devstack-gate

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
#  # Simulate Ironic
#  #  name: '{pipeline}-tempest-dsvm-ironic-pxe_ssh{job-suffix}'
#  # - devstack-virtual-ironic:
#  #     postgres: 0
#  #     build-ramdisk: 1
#  #     deploy_driver: pxe_ssh
#  #     deploy-with-ipa: 0
#  #     client-from-source: 0
#  #     ironic-lib-from-source: 0
#  #     ipxe-enabled: 0
#  #     branch-override: '{branch-override}'
#  #     tempest-env: 'DEVSTACK_GATE_TEMPEST_REGEX=baremetal'
#  #     devstack-timeout: 120
#  export PROJECTS="openstack/ironic $PROJECTS"
#  export PROJECTS="openstack/ironic-lib $PROJECTS"
#  export PROJECTS="openstack/ironic-python-agent $PROJECTS"
#  export PROJECTS="openstack/python-ironicclient $PROJECTS"
#  export PYTHONUNBUFFERED=true
#  export DEVSTACK_GATE_TIMEOUT=120
#  export DEVSTACK_GATE_TEMPEST=1
#  export DEVSTACK_GATE_POSTGRES=0
#  export DEVSTACK_GATE_IRONIC=1
#  export DEVSTACK_GATE_NEUTRON=1
#  export DEVSTACK_GATE_VIRT_DRIVER=ironic
#  export DEVSTACK_GATE_IRONIC_DRIVER=pxe_ssh
#  export DEVSTACK_GATE_IRONIC_BUILD_RAMDISK=1
#  export TEMPEST_CONCURRENCY=1
#  export BRANCH_OVERRIDE=default
#  if [ "$BRANCH_OVERRIDE" != "default" ] ; then
#      export OVERRIDE_ZUUL_BRANCH=$BRANCH_OVERRIDE
#  fi
#  
#  export IRONICCLIENT_FROM_SOURCE=0
#  if [ "$IRONICCLIENT_FROM_SOURCE" == "1" ]; then
#      export DEVSTACK_PROJECT_FROM_GIT="python-ironicclient"
#  fi
#  
#  export IRONIC_LIB_FROM_SOURCE=0
#  if [ "$IRONIC_LIB_FROM_SOURCE" == "1" ]; then
#      export DEVSTACK_PROJECT_FROM_GIT="ironic-lib"
#  fi
#  
#  # The IPA ramdisk needs at least 1GB of RAM to run
#  export DEVSTACK_LOCAL_CONFIG="IRONIC_VM_SPECS_RAM=1024"$'\n'"IRONIC_VM_COUNT=1"
#  
#  export DEPLOY_WITH_IPA=0
#  if [ "$DEPLOY_WITH_IPA" == "1" ] ; then
#      export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_DEPLOY_DRIVER_ISCSI_WITH_IPA=True"
#  fi
#  
#  export IPXE_ENABLED=0
#  if [ "$IPXE_ENABLED" == "1" ] ; then
#      export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_IPXE_ENABLED=True"
#  fi
#  
#  # Allow switching between full tempest and baremetal-only
#  export DEVSTACK_GATE_TEMPEST_REGEX=baremetal
#  
#  # devstack plugin didn't exist until mitaka
#  if [[ "$ZUUL_BRANCH" != "stable/kilo" && "$ZUUL_BRANCH" != "stable/liberty" ]] ; then
#      export DEVSTACK_LOCAL_CONFIG+=$'\n'"enable_plugin ironic git://git.openstack.org/openstack/ironic"
#  fi
#  
#  cp devstack-gate/devstack-vm-gate-wrap.sh ./safe-devstack-vm-gate-wrap.sh
#  ./safe-devstack-vm-gate-wrap.sh 2>&1 | tee ~/output.log
#  exit


# From openstack-infra/project-config/jenkins/jobs/devstack-gate.yaml
# ***************** Grenade stuff ************************
# Local mods
export PROJECTS="openstack/ironic $PROJECTS"
export PROJECTS="openstack/ironic-lib $PROJECTS"
export PROJECTS="openstack/ironic-python-agent $PROJECTS"
export PROJECTS="openstack/python-ironicclient $PROJECTS"
export PROJECTS="openstack-dev/grenade $PROJECTS"
export PYTHONUNBUFFERED=true
export GIT_BASE=https://git.openstack.org/
export DEVSTACK_GATE_TIMEOUT=120
export DEVSTACK_GATE_TEMPEST=1
export DEVSTACK_GATE_GRENADE=pullup
export DEVSTACK_GATE_IRONIC=1
export DEVSTACK_GATE_NEUTRON=1
export DEVSTACK_GATE_VIRT_DRIVER=ironic

# BEGIN: Since stable/mitaka ********************************************************
#export DEVSTACK_GATE_TEMPEST_ALL_PLUGINS="1"
export GRENADE_PLUGINRC="enable_grenade_plugin ironic https://git.openstack.org/openstack/ironic"

# Run only baremetal tests
export DEVSTACK_GATE_TEMPEST_REGEX="baremetal"
## I think in the future the REGEX changes to 'ironic'


# END: Since stable/mitaka **********************************************************

#export TEMPEST_CONCURRENCY=2
export TEMPEST_CONCURRENCY=1


export DEVSTACK_LOCAL_CONFIG="IRONIC_DEPLOY_DRIVER_ISCSI_WITH_IPA=True"


# Use TinyIPA
export IRONIC_RAMDISK_TYPE=tinyipa
export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_VM_SPECS_RAM=512"
export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_VM_COUNT=3"


# For CoreOS
#export IRONIC_RAMDISK_TYPE=coreos
# The CoreOS IPA ramdisk needs at least 1GB of RAM to run
#export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_VM_SPECS_RAM=1024"
#export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_VM_COUNT=1"


export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_RAMDISK_TYPE=$IRONIC_RAMDISK_TYPE"


# export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_HW_NODE_DISK=2"
# export DEVSTACK_LOCAL_CONFIG+=$'\n'"IRONIC_VM_SPECS_DISK=2"

# JLV set GIT_BASE since those devstack people refuse to change to a sensible
# default and insist on using 'git://' :(  Yay for insecurity!
export DEVSTACK_LOCAL_CONFIG+=$'\n'"GIT_BASE=https://git.openstack.org/"


# export BRANCH_OVERRIDE={branch-override}
export BRANCH_OVERRIDE=default
if [ "$BRANCH_OVERRIDE" != "default" ] ; then
export OVERRIDE_ZUUL_BRANCH=$BRANCH_OVERRIDE
fi
cp devstack-gate/devstack-vm-gate-wrap.sh ./safe-devstack-vm-gate-wrap.sh

# Pipe in /dev/null as had strange issues occur if didn't
./safe-devstack-vm-gate-wrap.sh </dev/null

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
