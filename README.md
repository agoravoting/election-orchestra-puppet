Election Orchestra Puppet
===========

Puppet-vagrant setup for election orchestra

Installation
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
===========
* vagrant ssh

TODO
===========
* replace references to vagrant with puppet urls (search for FIXME)

Troubleshooting)
===========

* Apply puppet manually with cd /vagrant; sudo puppet apply manifests/init.pp --modulepath modules/
