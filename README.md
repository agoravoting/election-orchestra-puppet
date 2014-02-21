# Election Orchestra Puppet

Puppet-vagrant setup for election orchestra


## Installation (vagrant)

### Install vagrant

* http://www.vagrantup.com

### Download the repository

*	git clone https://github.com/agoraciudadana/election-orchestra-puppet.git

### Install the puppet-python module

* cd election-orchestra-puppet/modules
* git clone git://github.com/stankevich/puppet-python.git python
* cd ..

### Edit your configuration

The basic configuration of your authority will be in election-orchestra-puppet/manifests/init.pp. Take a look at it and edit accordingly.

### Run

* vagrant up

### Accessing the vm

* vagrant ssh
* sudo -s
* su - eorchestra

### Applying puppet manually inside the vm

Apply puppet manually with

* cd /vagrant; sudo puppet apply manifests/init.pp --modulepath modules/



## Standalone installation (no vagrant)

### Download the repository

First download election-orchestra-puppet

* git clone https://github.com/agoraciudadana/election-orchestra-puppet.git

### Install the puppet-python module

* cd election-orchestra-puppet/modules
* git clone git://github.com/stankevich/puppet-python.git python
* cd ..

### Edit your configuration

The basic configuration of your authority will be in election-orchestra-puppet/manifests/init.pp. Take a look at it and edit accordingly.

## Finish installation

* sudo shell/apt.sh
* sudo puppet apply manifests/init.pp --modulepath modules/



## Usage

## Managing peer packages

Part of the security of this particular kind of election-orchestra deployment method comes from only allowing connection from trusted peers. This is because we limit connections from known peers by SSL certificate and IP address.

To add another peers, ask them for their "peer package". This is a very simple file that contains the SSL certificate, IP address and hostname of the peer. When you setup your authority, you need to add the peer packages of the agora-ciudadana servers that can create elections and the other election-orchestra authorities you recognize and trust.

To generate your own peer package, execute:

* sudo eopeers --show-mine

Which will print something similar to:

* {
*   "ssl_certificate": "some certificate",
*   "ip_address": "1.1.1.1",
*   "hostname": "the-example-auth"
* }

You can can copy that and send it via email or other means to your peers. They will also have to send their peer packages. If it's an already installed peer package which has changed the ip-address or ssl-certificate, those parameters will get updated.

You can install an individual package file this way:

* sudo eopeers --install <path/to/peer.package>

Which should output nothing if everything goes well.

You can install a list of peer packages at once too:

* sudo eopeers --install <path/to/peer1.package> <path/to/peer1.package> ...

Typically, someone you trust might send you a tarball with a bunch of peer packages. So what you would do is something like:

* tar zxf packages.tar.gz
* sudo eopeers --install packages/*.package
* sudo service nginx restart # restart nginx to apply changes

You can also list all installed packages:

* sudo eopeers --list
* Packages in /etc/eopeers:
*  * peer1
*  * peer2
*  * agoravoting

And remove a peer package by hostname:

* sudo eopeers --uninstall peer1
* sudo service nginx restart # restart nginx to apply changes

## Managing backups

As an election authority, it's critical that you have an appropiate backup system. We provide some scripts that will help you create and restore backups of all the important data.

To create a new backup in /backups dir, just execute the following command:

* sudo create_backup.sh

To restore a backup, do something like for example (you need to change the path of the backup):

* sudo restore_backup.sh

