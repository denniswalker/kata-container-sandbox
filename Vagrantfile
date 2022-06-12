# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "opensuse/Leap-15.3.x86_64"

  config.vm.provider "virtualbox" do |vb|
    # vb.gui = true
    vb.memory = "4096"
    vb.cpus = 2
    vb.customize ['modifyvm', :id, '--nested-hw-virt', 'on']
  end
  config.vm.provision "shell", path: "METAL.sh"
  config.vm.provision "shell", path: "stuff_we_have.sh"
  config.vm.provision "shell", path: "PET.sh"
  config.vm.provision "shell", path: "CMS.sh"
end
