# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

# Vagrant plugins that need to be installed. Versions will vary.
# vagrant-libvirt (0.0.32)  - if using libvirt
# vagrant-mutate (1.0.4)    - if using libvirt
# vagrant-proxyconf (1.5.2) - if behind a proxy server

# Default https://atlas.hashicorp.com/ubuntu/xenial64 doesn't work
Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')

# Used by vagrant-proxyconf
use_proxy = !((ENV['http_proxy'].nil? || ENV['http_proxy'].empty?) &&
              (ENV['https_proxy'].nil? || ENV['https_proxy'].empty?))


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
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

  # Make the VM be named 'devstack' instead of 'default'
  config.vm.define "devstack" do |devstack|
  end

  # config.vm.network :public_network

  # This check does NOT work if they use '--provider' :(
  if ENV['VAGRANT_DEFAULT_PROVIDER'] == 'libvirt'

      # ******************* Start Libvirt ******************************

      puts("Assuming provider is libvirt...")

      # Assumption here is have converted the 'ubuntu/xenial64' Virtualbox box to a
      # libvirt format using 'vagrant mutate' (which needs to be installed) and
      # named the converted box 'xenial64'
      # https://github.com/pradels/vagrant-libvirt
      # https://github.com/sciurus/vagrant-mutate

      # Check for required plugins
      unless Vagrant.has_plugin?("vagrant-libvirt")
            raise 'vagrant-libvirt (https://github.com/pradels/vagrant-libvirt) is not installed'
      end
      unless Vagrant.has_plugin?("vagrant-mutate")
            raise 'vagrant-mutate (https://github.com/sciurus/vagrant-mutate) is not installed'
      end

      config.vm.box = "xenial64"

      # We use libvirt to have nested virtualization
      config.vm.provider :libvirt do |domain|
        domain.memory = 8192
        domain.cpus = 4
        domain.nested = true
        domain.volume_cache = 'none'
      end

      # This might be needed for Ansible
      config.vm.network :private_network, ip: "192.168.32.100"

      # ******************* End Libvirt ******************************

  else

      # ******************* Start Virtualbox ******************************

      puts("Assuming provider is Virtualbox...")

      # For Virtualbox using 'ubuntu/xenial64'
      config.vm.box = "ubuntu/xenial64"

      config.vm.provider "virtualbox" do |domain|
        domain.memory = 8192
        domain.cpus = 4
      end

      # This might be needed for Ansible
      config.vm.network :private_network, ip: "192.168.64.100"

      # ******************* End Virtualbox ******************************

  end

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
