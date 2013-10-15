* Install

Install the python module

cd modules
git clone git://github.com/stankevich/puppet-python.git python

* Run

vagrant up

* Access vm

vagrant ssh

* TODO

replace references to vagrant with puppet urls (search for FIXME)

* Applying puppet manually (for troubleshooting)

cd /vagrant
sudo puppet apply manifests/init.pp --modulepath modules/