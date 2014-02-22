Setup
=====

The easiest set up is one git clone of election-orchestra-puppet per authority targeting different folders on the host machine. 

* Follow the instructions in election-orchestra-puppet readme for vagrant install

* Vagrantfile (for each authority)

    * config.vm.host_name = "agoravoting-eovm+n"

    * comment the port redirections:

        config.vm.network "forwarded_port", guest: 5000, host: 5000
        
        config.vm.network "forwarded_port", guest: 4081, host: 4081
        
        config.vm.network "forwarded_port", guest: 8081, host: 8081

    * uncomment the private network line:

        config.vm.network "private_network", ip: "192.168.50.2+n"    

    * manifests/init.pp:

        host => 'agoravoting-eovm+n'

        If you forget to make these changes before vagrant up you can use vagrant reload to alter the configuration

* vagrant up

* Set up /etc/hosts

    Replace 127.0.0.1 with the vms ip 
    add ips for the other authorities (according to the ip assigned in the vagrant file)

    For example, for two authorities, the /etc/hosts would be

    192.168.50.2 agoravoting-eovm

    192.168.50.3 agoravoting-eovm2

    
    192.168.50.3 agoravoting-eovm2

    192.168.50.2 agoravoting-eovm

* Append each authority’s certificate (/srv/certs/selfsigned/cert.pem) into every other’s authority’s calist (/srv/certs/selfsigned/calist)

* Specify ip's base_settings.py on each authority - sudo vi /home/eorchestra/election-orchestra/base_settings.py

    the following entries:

    VERIFICATUM_SERVER_URL 

    VERIFICATUM_HINT_SERVER_SOCKET 

    should be in the form of ipaddresses not hostnames, as in

    VERIFICATUM_SERVER_URL = 'http://192.168.50.2'

    VERIFICATUM_HINT_SERVER_SOCKET = '192.168.50.2'

* restart nginx and eorchestra on each authority 

    sudo /etc/init.d/nginx restart

    sudo supervisorctl restart eorchestra

* Install nodejs - sudo apt-get install nodejs

* Clone agora-ciudadana inside the /vagrant/test directory

     cd /vagrant/test
     git clone https://github.com/agoraciudadana/agora-ciudadana.git
     cd agora-ciudadana
     git checkout security 

* Set up eo_test.py

    * Copy the certificates into the ssl_cert json fields in the authoritiesData variable in eo_test.py

    * Activate the virtual environment

      source venv/bin/activate in /home/eorchestra

* Run

    python eo_test.py --help
 

Troubleshooting
========

* Invalid socket address: probably means there is an old instance of verificatum running. Running

    sudo supervisorctl restart eorchestra

    should kill these processes

* Verificatum hangs: did you forget to use ip’s instead of hostnames in the base_settings.py?

    if so, change the file and restart eorchestra

    sudo supervisorctl restart eorchestra