# -*- mode: ruby -*-
# vi: set ft=ruby :


# Vagrant plugins that need to be installed. Versions will vary.
# vagrant-libvirt (0.0.32)  - if using libvirt
# vagrant-mutate (1.0.4)    - if using libvirt
# vagrant-proxyconf (1.5.2) - if behind a proxy server

# Used by vagrant-proxyconf
use_proxy = !((ENV['http_proxy'].nil? || ENV['http_proxy'].empty?) &&
              (ENV['https_proxy'].nil? || ENV['https_proxy'].empty?))


Vagrant.configure(2) do |config|
  # Configure plugins, using the proxy plugin
  # https://github.com/tmatilai/vagrant-proxyconf/
  if use_proxy
    if Vagrant.has_plugin?("vagrant-proxyconf")
      config.proxy.http = ENV['http_proxy']
      config.proxy.https = ENV['https_proxy']
      config.proxy.no_proxy = ENV['no_proxy']
    else
      raise "vagrant-proxyconf (https://github.com/tmatilai/vagrant-proxyconf/) is not installed and proxy being used"
    end
  end

  # Use NFS synced folder, make sure have installed NFS server on host
  config.vm.synced_folder "/opt/git", "/opt/git", type: "nfs"

  # config.vm.network :public_network

  # ******************* Start Libvirt ******************************
  # Assumption here is have converted the 'ubuntu/trusty64' Virtualbox box to a
  # libvirt format using 'vagrant mutate' (which needs to be installed) and
  # named the converted box 'trusty64'
  # https://github.com/pradels/vagrant-libvirt
  # https://github.com/sciurus/vagrant-mutate


  # We use libvirt to have nested virtualization
  config.vm.provider :libvirt do |domain, override|
    # Check for required plugins
    unless Vagrant.has_plugin?("vagrant-libvirt")
          raise 'vagrant-libvirt (https://github.com/pradels/vagrant-libvirt) is not installed'
    end
    unless Vagrant.has_plugin?("vagrant-mutate")
          raise 'vagrant-mutate (https://github.com/sciurus/vagrant-mutate) is not installed'
    end
    override.vm.box = "trusty64"
    domain.memory = 8192
    domain.cpus = 4
    domain.nested = true
    domain.volume_cache = 'none'
    # This might be needed for Ansible
    override.vm.network :private_network, ip: "192.168.32.100"
  end
  # ******************* End Libvirt ********************************

  # ******************* Start Virtualbox ***************************
  config.vm.provider "virtualbox" do |domain, override|
    override.vm.box = "ubuntu/trusty64"
    domain.memory = 8192
    domain.cpus = 4
    # This might be needed for Ansible
    override.vm.network :private_network, ip: "192.168.64.100"
  end
  # ******************* End Virtualbox *****************************

  # Do ansible setup
  config.vm.provision :ansible do |ansible|
    ansible.sudo = true
    ansible.sudo_user = "root"
    ansible.playbook = "ansible/playbook.yml"
    # ansible.inventory_path = "ansible/inventory"
    ansible.verbose = true
#    ansible.verbose = "vvvv"
    ansible.limit = "all"
  end

end
