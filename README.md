Election Orchestra Puppet
===========

Puppet-vagrant setup for election orchestra

Installation (vagrant)
===========

Install vagrant
---------
* http://www.vagrantup.com

Download the repository
---------
*	git clone https://github.com/agoraciudadana/election-orchestra-puppet.git

Install the puppet-python module
---------
* cd election-orchestra-puppet/modules
* git clone git://github.com/stankevich/puppet-python.git python

Run
---------
* vagrant up

Accessing the vm
---------
* vagrant ssh
* sudo -s
* su - eorchestra

Applying puppet manually inside the vm
---------

* Apply puppet manually with cd /vagrant; sudo puppet apply manifests/init.pp --modulepath modules/

Standalone installation (no vagrant)
===========

* git clone https://github.com/agoraciudadana/election-orchestra-puppet.git
* cd election-orchestra-puppet
* sudo shell/apt.sh
* sudo puppet apply manifests/init.pp --modulepath modules/