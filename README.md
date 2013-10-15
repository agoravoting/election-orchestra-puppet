Election Orchestra Puppet
===========

Puppet-vagrant setup for election orchestra

Installation
===========

* Install virtualbox (https://www.virtualbox.org/)
* Install vagrant (http://www.vagrantup.com/)
* Install the python module

cd modules

git clone git://github.com/stankevich/puppet-python.git python

* Run

vagrant up

Accessing the vm
===========


vagrant ssh

TODO
===========
* replace references to vagrant with puppet urls (search for FIXME)

* Applying puppet manually (for troubleshooting)

cd /vagrant

sudo puppet apply manifests/init.pp --modulepath modules/