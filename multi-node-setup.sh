#!/bin/bash

if [ ! -f ~/.ssh/id_rsa ]; then
    echo "You don't have a ~/.ssh/id_rsa file."
    echo "How the heck are we going to log into the subnode???"
    echo "A key should be generated and should be able to login and sudo on the other node using that key"
    exit 1
fi

if [[ $# -lt 2 ]] ; then
     echo 'Please provide primary private IP and sub private IP'
     exit 0
fi


# Create our hosts file
echo "Creating the hosts file..."
cat << EOF > hosts
$1
$2
EOF

rm -rf host_vars/

# Let's go get facts about these hosts
echo "Collecting facts about our hosts..."
rm -rf facts_about_hosts/
ansible -i hosts all -m setup --tree facts_about_hosts/ > /dev/null

# On OSIC cluster it is all IPv6 for public IP addresses
echo "Determining IPv6 addresses..."
primary_ipv6=$(jq ' .ansible_facts.ansible_all_ipv6_addresses[0]' facts_about_hosts/${1})
subnode_ipv6=$(jq ' .ansible_facts.ansible_all_ipv6_addresses[0]' facts_about_hosts/${2})

# Create our host variables
echo "Creating the host_vars files..."
rm -rf host_vars/
mkdir host_vars
# Create primary node variables
cat << EOF > host_vars/$1
---
primary_ip: $1
primary_ipv6: ${primary_ipv6}
subnode_ip: $2
subnode_ipv6: ${subnode_ipv6}
node_ip: $1
node_role: primary
EOF

# Create subnode variables
cat << EOF > host_vars/$2
---
primary_ip: $1
primary_ipv6: ${primary_ipv6}
subnode_ip: $2
subnode_ipv6: ${subnode_ipv6}
node_ip: $2
node_role: sub
EOF

# Create a provider.txt file if it doesn't exist:
if [ ! -f provider.txt ]; then
	cat << EOF > /etc/nodepool/provider
NODEPOOL_PROVIDER='osic-cloud1-s3500'
NODEPOOL_CLOUD='osic-cloud1'
NODEPOOL_REGION='RegionOne'
NODEPOOL_AZ=''
EOF
fi

ansible-playbook -i hosts -vvv playbook.yml
