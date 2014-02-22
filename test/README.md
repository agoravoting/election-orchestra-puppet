# Setup

## Vagrant setup

The easiest set up is one git clone of election-orchestra-puppet per authority targeting different folders on the host machine. 

Follow the instructions in election-orchestra-puppet/README.md for vagrant install but changing the Vagrantfile for each of the authorities so that (n means the authority number):

* change hostname:
    config.vm.host_name = "agoravoting-eovm+n"

* comment or remove the port redirections:
    config.vm.network "forwarded_port", guest: 5000, host: 5000
    config.vm.network "forwarded_port", guest: 4081, host: 4081
    config.vm.network "forwarded_port", guest: 8081, host: 8081

* uncomment the private network line:
    config.vm.network "private_network", ip: "192.168.50.2+n"

* modify manifests/init.pp accordingly:
    host => 'agoravoting-eovm+n'
    ip_address => "192.168.50.2+n"

If you forget to make these changes before vagrant up you can use vagrant reload to alter the configuration

After that you can proceed with the instructions, so that you end up executing:

## Authorize connections among the authorities

Each authority needs to recognize each other. To do so, you just follow the instructions in election-orchestra-puppet/README.md regarding "eopeers" command. This is more or less what you'd have to do in each authority:

1. Get the peer package of the curren authority. Execute:
    sudo eopeers --show-mine

2. copy the output to a file in the other authority in /tmp/auth.package for example and then execute:
    sudo eopeers --install /tmp/auth.package

## Configure agora

To create votes we use the code in agora-ciudadana via nodejs. You need to:

1. Install nodejs
    sudo apt-get install nodejs

2. Clone agora-ciudadana inside the /vagrant/test directory
    cd /vagrant/test
    git clone https://github.com/agoraciudadana/agora-ciudadana.git
    cd agora-ciudadana
    git checkout security

3. Activate the virtual environment (in the future, you start from this step)
    source /home/eorchestra/venv/bin/activate

4. use eotest
    eotest --help
 
# Troubleshooting

* Invalid socket address

Probably means there is an old instance of verificatum running. Running the following command should kill the processes:
    sudo supervisorctl restart eorchestra

* Verificatum hangs

Did you forget to use ip’s instead of hostnames in the base_settings.py?  if so, change the file and restart eorchestra:
    sudo supervisorctl restart eorchestra
