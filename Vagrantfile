# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    # All Vagrant configuration is done here. The most common configuration
    # options are documented and commented below. For a complete reference,
    # please see the online documentation at vagrantup.com.

    config.vm.host_name = "agoravoting-eovm"

    if ENV['AWS_SECRET_ACCESS_KEY'].nil?
        config.vm.box = "eobox"
        config.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-10044-x64-vbox4210.box'
        config.vm.box_download_checksum = "95ab449006216771a3816bf17e4cc24e2775c0e63c00797f6a20f81ceb4bb35e"
        config.vm.box_download_checksum_type = "sha256"

        # quarantined, do not need this in dev mode, vms communicate through private network
        # config.vm.network "forwarded_port", guest: 5000, host: 5000
        # config.vm.network "forwarded_port", guest: 4081, host: 4081
        # config.vm.network "forwarded_port", guest: 8081, host: 8081

        # https://coderwall.com/p/n2y79g
        config.vm.provider "virtualbox" do |v|
            v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        end

        # for development setup
        config.vm.network "private_network", ip: "192.168.50.2"
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

    config.vm.provision :shell, :inline => "cd /vagrant/ && sh ./shell/bootstrap.sh"

    config.vm.provision :puppet , :module_path => "modules" , :options => "--verbose" do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file = "init.pp"
    end
end
