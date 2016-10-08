### figure out patch of a gerrit review

errexit=$(set +o | grep errexit)
set -o errexit
xtrace=$(set +o | grep xtrace)
set -o xtrace

# workaround non-writable $HOME of stack user :-/
export HTTPIE_CONFIG_DIR=/tmp/$USER-httpie-config


patch_repo() {
    local repo=${1:?repo not specified}
    local remote=${2:?remote not specified}
    local ref=${3:?ref not specified}

    pushd ${repo}
    flock -w 900 . bash -c \
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
    result=($(http GET https://review.openstack.org/changes/${number}/revisions/current/review | tail -n+2 | jq -er 'debug | if .status == "NEW" then ({project} + .revisions[.current_revision].fetch["anonymous http"])["project", "url","ref"] else false end | debug')) || return ${?}
    [ ${#result[@]} -eq 3 ] || return 1
    echo ${result[@]}
}
