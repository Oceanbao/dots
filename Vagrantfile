# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Box / OS 'bento/ubuntu-19.10'
VAGRANT_BOX = 'hashicorp/bionic64'
# Memorable name
VM_NAME = 'ubuntu'
# VM User - 'vagrant' by default
VM_USER = 'dele'

# Username on Mac
MAC_USER = 'dele'

# Host folder to sync
HOST_PATH = 'User/dele/'
# Where to sync to on Guest - 'vagrant' is default user name
GUEST_PATH = '/opt/project'

# VM Port - uncomment this to use NAT instead of DHCP
# VM_PORT = 8080

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Resize disk size
  # vagrant plugin install vagrant-disksize
  config.disksize.size = '120GB'
  config.vm.provision "shell", inline: <<-SHELL
    parted /dev/sda resizepart 1 100%
    pvresize /dev/sda1
    lvresize -rl +100%FREE /dev/mapper/vagrant--vg-root
  SHELL

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # Actual machine name
  config.vm.define VM_NAME do |t|
    t.vm.host_name = VM_NAME
    t.vm.box = VAGRANT_BOX
  end
  ## Launch 2 machines
  # config.vm.define "zipi" do |zipi|
  #     zipi.vm.host_name = "zipi"
  #     zipi.vm.box = "ubuntu/trusty64"
  #     zipi.vm.network "private_network", ip: "192.168.32.10",
  #         virtualbox__intnet: true, auto_config: true
  # config.vm.define "zape" do |zape|
  #     zipi.vm.host_name = "zape"
  #     zipi.vm.box = "ubuntu/trusty64"
  #     zipi.vm.network "private_network", ip: "192.168.32.11",
  #         virtualbox__intnet: true, auto_config: true

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # comment this out if planning on using NAT instead
  # config.vm.network "private_network", type: "dhcp"
  for i in 8080..8090
    config.vm.network "forwarded_port", guest: i, host: i,  auto_correct: true
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  # virtualbox__intnet: true, auto_config: true

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.

  # Sync folder
  # Disable default sync folder
  config.vm.synced_folder ".", "/vagrant", disabled: true
  # owner: "vagrant", group: "vagrant"
  # mount_options: ["dmode=755,fmode=664"]
  # Enable custom sync folder
  config.vm.synced_folder "/Users/dele/VOL_CON", "/home/vagrant/VOL_CON",
    owner: "vagrant", group: "vagrant",
    mount_options: ["dmode=755,fmode=755"]
  config.vm.synced_folder "/Users/dele/CODE", "/home/vagrant/CODE",
    owner: "vagrant", group: "vagrant",
    mount_options: ["dmode=755,fmode=755"]

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:

  # VM name in Virtualbox
  config.vm.provider "virtualbox" do |v|
    v.name = VM_NAME
    v.memory = 16385
    v.cpus = 12
  end

  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update -y
    apt-get install -y build-essential
    apt-get install -y curl
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    apt-key fingerprint 0EBFCD88
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
    curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  SHELL
end
