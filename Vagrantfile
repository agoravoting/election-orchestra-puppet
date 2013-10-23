# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"
 
  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"


  config.vm.define "first", primary: true do |first|
    first.vm.host_name = "first-eovm"
    first.vm.network "forwarded_port", guest: 5000, host: 5000
    first.vm.network "forwarded_port", guest: 4081, host: 4081
    first.vm.network "forwarded_port", guest: 8081, host: 8081
    first.vm.network "private_network", ip: "192.168.50.4"

    first.vm.provision :puppet , :module_path => "modules" , :options => "--verbose" do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file = "init.pp"
    end
  end

  config.vm.define "second" do |second|
    second.vm.host_name = "second-eovm"
    second.vm.network "forwarded_port", guest: 5001, host: 5001
    second.vm.network "forwarded_port", guest: 4082, host: 4082
    second.vm.network "forwarded_port", guest: 8082, host: 8082
    second.vm.network "private_network", ip: "192.168.50.5"

    second.vm.provision :puppet , :module_path => "modules" , :options => "--verbose" do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file = "second_init.pp"
    end
  end

  # config.vm.provision :shell, :inline => "apt-get update" 
  config.vm.provision :shell, :path => "shell/apt.sh"

  # https://coderwall.com/p/n2y79g
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end
end
