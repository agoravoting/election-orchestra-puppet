# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    # All Vagrant configuration is done here. The most common configuration
    # options are documented and commented below. For a complete reference,
    # please see the online documentation at vagrantup.com.

    config.vm.host_name = "agoravoting-eovm"

    if ENV['AWS_SECRET_ACCESS_KEY'].nil?
        config.vm.box = "precise64"
        config.vm.box_url = "http://files.vagrantup.com/precise64.box"
        config.vm.box_download_checksum = "9a8bdea70e1d35c1d7733f587c34af07491872f2832f0bc5f875b536520ec17e"
        config.vm.box_download_checksum_type = "sha256"

        config.vm.network "forwarded_port", guest: 5000, host: 5000
        config.vm.network "forwarded_port", guest: 4081, host: 4081
        config.vm.network "forwarded_port", guest: 8081, host: 8081

        # https://coderwall.com/p/n2y79g
        config.vm.provider "virtualbox" do |v|
            v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        end

        # for development setup
        # config.vm.network "private_network", ip: "192.168.50.2"
    else
        config.vm.box = "dummy"
        config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
        config.ssh.username = "ubuntu"

        config.vm.provider "aws" do |aws, override|
            override.ssh.private_key_path = ENV['AWS_PRIVKEY_PATH']
            override.ssh.username = "ubuntu"

            aws.access_key_id =  ENV['AWS_ACCESS_KEY_ID']
            aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
            aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
            aws.security_groups = [ENV["AWS_SECURITY_GROUP"]]
            aws.region = "eu-west-1"
            aws.ami = "ami-4c9b7d3b"
            aws.instance_type = "c1.medium"
            aws.tags = {
                Name: 'Vagrant AWS Election-orchestra'
            }

            aws.region_config "es-west-1" do |region|
                region.terminate_on_shutdown = true
            end
        end
    end

    config.vm.provision :shell, :path => "shell/apt.sh"

    config.vm.provision :puppet , :module_path => "modules" , :options => "--verbose" do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file = "init.pp"
    end
end
