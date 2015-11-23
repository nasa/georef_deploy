# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  # using ubuntu cloud images seems to create problems with host-only networking. feh.
  #   will just use vagrant's default trusty64 instead, shall we?
  # config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/trusty-server-cloudimg-amd64-juju-vagrant-disk1.box"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2

    # run "VAGRANT_GUI=1 vagrant up" to get a display; default is headless mode
    if ENV['VAGRANT_GUI'] != nil
      vb.gui = true
    end
  end

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network "private_network", ip: "10.0.3.18"

  # need a hostname or puppet will complain
  config.vm.hostname = "georef.vagrant"

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  config.vm.synced_folder "georef/", "/home/vagrant/gds/georef", owner: "vagrant", group: "vagrant"

  config.vm.provision "shell", privileged: false, path: "setup_site_vagrant.py"
  config.ssh.pty = true
end
