Setup
=====

The easiest set up is one git clone of election-orchestra-puppet per authority targeting different folders on the host machine. 

For _each_ authority:

1) Follow the instructions in election-orchestra-puppet readme for vagrant install, then

For each authority (for n = 2 upwards after the first authority)

Vagrantfile

config.vm.host_name = "agoravoting-eovm+n"

* comment the port redirections:

config.vm.network "forwarded_port", guest: 5000+n, host: 5000+n
config.vm.network "forwarded_port", guest: 4081+n, host: 4081+n
config.vm.network "forwarded_port", guest: 8081+n, host: 8081+n

* uncomment the private network line:

config.vm.network "private_network", ip: "192.168.50.2+n"    

* manifests/init.pp:

host => 'agoravoting-eovm+n'

If you forget to make these changes before vagrant up you can use vagrant reload to alter the configuration

2) vagrant up

3) Set up /etc/hosts

Replace 127.0.0.1 with the vms ip 
add ips for the other authorities (according to the ip assigned in the vagrant file)

For example, for two authorities, the /etc/hosts would be

192.168.50.2 agoravoting-eovm
192.168.50.3 agoravoting-eovm2

192.168.50.3 agoravoting-eovm2
192.168.50.2 agoravoting-eovm

4) Append each authority’s certificate (/srv/certs/selfsigned/cert.pem) into every other’s 

authority’s calist (/srv/certs/selfsigned/calist)

5) Specify ip's base_settings.py on each authority - sudo vi /home/eorchestra/election-orchestra/base_settings.py

the following entries:

VERIFICATUM_SERVER_URL 

VERIFICATUM_HINT_SERVER_SOCKET 

should be in the form of ipaddresses not hostnames, as in

VERIFICATUM_SERVER_URL = 'http://192.168.50.2'
VERIFICATUM_HINT_SERVER_SOCKET = '192.168.50.2'

6) restart nginx and eorhcestra on each authority 

sudo /etc/init.d/nginx restart
sudo supervisorctl restart eorchestra

7) Install nodejs - sudo apt-get install nodejs

8) Clone agora-ciudadana inside the /vagrant/test directory

 cd /vagrant/test
 git clone git@github.com:agoraciudadana/agora-ciudadana.git
 git checkout security 

9) Set up eo_test.py

* Copy the certificates into the ssl_cert json fields in the startUrl variable in eo_test.py

* Activate the virtual environment

source venv/bin/activate in the /home/eorchestra
 



