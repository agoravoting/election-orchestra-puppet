# Election Orchestra Puppet

Puppet-vagrant setup for election orchestra

## Installation (vagrant)

### Install vagrant

* http://www.vagrantup.com

### Download the repository

    $ git clone https://github.com/agoravoting/election-orchestra-puppet.git

### Edit your configuration

The basic configuration of your authority is in
election-orchestra-puppet/manifests/init.pp. Take a look at it and edit
accordingly. See more information below in the "Edit Configuration section"
for Standalone installation (the configuration settings are the same).

### Run

    $ vagrant up

### Accessing the vm

    $ vagrant ssh
    $ sudo -s
    $ su - eorchestra

### Applying puppet manually inside the vm

Apply puppet manually with

    $ cd /vagrant; sudo puppet apply manifests/init.pp --modulepath modules/

## Standalone installation (no vagrant)

You'll need an Ubuntu 14.04 LTS 64 bits fresh installed server, and then:

### Download the repository

Install the dependencies (with root superuser):

    # apt-get update
    # apt-get install -y git

Download election-orchestra-puppet. You can do that with a typical unix user,
just remember the download path:

    $ git clone https://github.com/agoravoting/election-orchestra-puppet.git
    $ cd election-orchestra-puppet

### Edit your configuration

The basic configuration of your authority will be in
election-orchestra-puppet/manifests/init.pp. Take a look at it and edit
accordingly.

Some important notes about the configuration parameters:
 * Usually both "private_ipaddress" and "public_ipaddress" variables should be
   the same. But in Amazon AWS the public ip address is not directly addresable
   by the machine; it's addresable with other ip address. Only in this kind of
   case the private ip address should not be the same as the public one. In NO
   case the private ip address should be set as "127.0.0.1.

 * In the case of Amazon AWS, you also need to setup the cloud firewall (which
   is NOT the internal machine firewall, but one setup externally throught
   "Security Groups") to allow *inbound* connections on the TCP/UDP ports
   specified in the configuration. This might also be needed in other similar
   setups. Here is a list of the ports used, specifed in the manifests/init.pp
   configuration file:
  - "port" is 5000 by default and uses TCP connections
  - "verificatum_server_ports" is 4081 by default (4081-4083 but only first is
    curently used), and uses TCP connections
  - "verificatum_hint_server_ports" is 8081 by default (8081-8083 but only
    first is curently used), and uses UDP connections

 * In general, there's usually no reason/need to change the default ports
   configuration in settings.

 * The "hostname" is used as the name other authorities will address this
   machine. For improved security, election-orchestra-puppet does not rely on
   DNS information for ip address resolution, but uses the information setup
   with the keys "hostname" and "public_ipaddress" and via "eopeers" command
   for adress resolution. The name of the machine should just be an addresable
   machine name like "agoravoting-whatever" or "pepito".

 * The "backup_password" is stored in /root/.backup_password and is used to
   automatically encrypt/decrypt with gpg when creating or restoring backups.
   Backups are explained explained below in a subsection.

 * The "auto_mode" is explained later on in a subsection of this document. If
   "auto_mode" is set to true, the two operations "create publickey for an
   election" and "tally an election" will be performed automatically without the
   need of the confirmation by the authority operator. This is set true by
   default because it's good for testing, but for important election and
   improved security you should set it to false as explained below.

### Finish installation

Be careful with locales. Your installation might have a different locale than
we asume and that can be really problematic. Please be sure that en_GB.UTF-8 is
available and use it. For example do:

    $ export LC_ALL=en_US.UTF-8

Then execute:

    $ sudo sh shell/bootstrap.sh
    $ sudo puppet apply manifests/init.pp --modulepath modules/


## Usage

## Managing peer packages

Part of the security of this particular kind of election-orchestra deployment
method comes from only allowing connection from trusted peers. This is because
we limit connections from known peers by SSL certificate and IP address.

To add another peers, ask them for their "peer package". This is a very simple
file that contains the SSL certificate, IP address and hostname of the peer.
When you setup your authority, you need to add the peer packages of the
agora-ciudadana servers that can create elections and the other
election-orchestra authorities you recognize and trust.

To generate your own peer package, execute:

    $ sudo eopeers --show-mine

Which will print something similar to:

    {
      "ssl_certificate": "some certificate",
      "ip_address": "1.1.1.1",
      "hostname": "the-example-auth"
    }

You can can copy that and send it via email or other means to your peers. They will also have to send their peer packages. If it's an already installed peer package which has changed the ip-address or ssl-certificate, those parameters will get updated.

You can install an individual package file this way:

    $ sudo eopeers --install <path/to/peer.pkg>

Which should output nothing if everything goes well.

You can install a list of peer packages at once too:

    $ sudo eopeers --install <path/to/peer1.pkg> <path/to/peer1.pkg> ...

Typically, someone you trust might send you a tarball with a bunch of peer packages. So what you would do is something like:

    $ tar zxf packages.tar.gz
    $ sudo eopeers --install packages/*.pkg
    $ sudo service nginx restart # restart nginx to apply changes

You can also list all installed packages:

    $ sudo eopeers --list
    Packages in /etc/eopeers:
      * peer1
      * peer2
      * agoravoting

And remove a peer package by hostname:

    $ sudo eopeers --uninstall peer1
    $ sudo service nginx restart # restart nginx to apply changes

## Managing backups

As an election authority, it's critical that you have an appropiate backup system. We provide some scripts that will help you create and restore backups of all the important data.

To create a new backup in /backups dir, just execute the following command:

    $ sudo create_backup.sh

To restore a backup, do something like for example (you need to change the path of the backup):

    $ sudo restore_backup.sh <path/to/backup>

## Update installation

Sometimes you might need to update the system. You will probably have to download first the last updates from the election-orchestra-puppet directory with "git pull".

After that, what you will have to do is to create a backup (as explained previously), copy your backup somewhere safe, and then create a fresh election-orchestra-puppet installation and then restore there your backup.

## Automatic/manual modes

There are two modes for working in election-orchestra: automatic and manual. This has to do with the election-orchestra requests from other peers, which are of two types: either create election public keys, or perform a tally.

The automatic mode accepts requests from allowed peers without requesting a confirmation from the authority administrator. Automatic mode is good for testing and also for public election authorities.

Manual mode needs the confirmation from the election authority administrator. This is good for improved security, for example to be able to confirm by other means that the tally request is legit, or to check the request data itself. It's useful for important elections.

Note that the default mode in a deployment is automatic, and this can be changed in manifests/init.pp with the variable "auto_mode". You can also check its value with:

    $ sudo eoauto

Or change it:

    $ sudo eoauto true

But the best way to do it is change it in manifests/init.pp and then executing puppet again (and restarting eorchestra with "supervisorctl restart eorchestra").

## Execute a test tally

If you have at least one peer package installed (and the peer has your peer package installed too), you can test your setup manually using eotest. To do a complete test you can just do:

    $ sudo eotest full --vmnd --vcount 100

Alternatively, to do it step by step, first we have to create the election, which will use yours as the director authority and all the other configured (the one that "eopeers --list" show) as performers:

    $ sudo eotest create

This command will output the id of the created election. Now you need to create the encrypted votes, for example 10.000 votes:

    $ sudo eotest encrypt <id> --vmnd --vcount 100

And finally perform the tally:

    $ sudo eotest tally <id>

## Watching the election-orchestra log

It's quite useful to look at the log live to see what's happening. You can do that this way (you can stop watching with <Ctrl>+<C>):

    $ sudo eolog

## Reset a tally

Sometimes there's some kind of problem with a tally, and you need to launch it again. In that case, you need to reset it first. You can either list the tallied election, ordered by "last tallied is first listed":

    $ sudo reset-tally

And reset a tally of an election by election-id:

    $ sudo reset-tally <election-id>

## Troubleshooting

If you have problems, you should take a look at the log executing the "sudo eolog" command. You'll see a quite verbose output. Here is a list of the typical problems and their usual solutions:

* Error: Puppet::Parser::AST::Resource failed with error ArgumentError: Invalid resource type anchor

Execute in vagrant with root user:

    puppet module install -i /vagrant/modules/ puppetlabs-stdlib

Exit vagrant and execute:

    vagrant provision

* Invalid socket address

Probably means there is an old instance of verificatum running. Running the following command should kill the processes:
    sudo supervisorctl restart eorchestra

If you're using amazon or some service where the internal private ip address is not the same as the public ip address, setup your ip public/private addresses accordingly in manifests/init.pp

* Verificatum hangs

Did you forget to use ip’s instead of hostnames in the base_settings.py?  if so, change the file and restart eorchestra:
    sudo supervisorctl restart eorchestra

Sometimes there are additional entries in /etc/hosts that need to be commented, for example

    127.0.1.1     agoravoting-eovm

Needs to be commented so that the correct entry (eg 192.168.50.2 agoravoting-eovm) takes effect

If you're using amazon or some service where the internal private ip address is not the same as the public ip address, setup your ip  public/private addresses accordingly in manifests/init.pp

* Verificatum crashes during a tally with  "Exception in thread "main" java.lang.ArithmeticException: / by zero" (at ArrayWorker.java:86)

This occurs if you attempt to run a tally for an election with 0 votes. If this happens you must restart eorchestra and also kill
any verificatum processes.

* verify_and_publish_tally error

A traceback such as the following appears:

    Traceback (most recent call last):
    File "build/bdist.linux-x86_64/egg/frestq/tasks.py", line 1268, in post_task
    task_output = task.run_action_handler()
    File "build/bdist.linux-x86_64/egg/frestq/tasks.py", line 286, in run_action_handler
    return self.action_handler(self)
    File "./tally_election/performer_jobs.py", line 413, in verify_and_publish_tally "election_id = %s" % election_id))
    TaskError

This occurs if you run a tally on an election for which a tally file already exists. You must first reset the tally with

    $ sudo reset-tally <election-id>

* General out of memory errors

  Verificatum may be killed by the kernel when it is using too much memory. This may show up in the eolog output with the unexpected message

  "Killed"

  as output for some os subprocess call by election orchestra. To diagnose this, inspect the kernel log, for example in ubuntu:

  vi /var/log/kern.log

  The following example shows that the kernel killed verificatum:

  Oct  6 23:08:58 wadobo-auth1 kernel: [527984.864767] Out of memory: Kill process 8734 (java) score 660 or sacrifice child
  Oct  6 23:08:58 wadobo-auth1 kernel: [527984.864799] Killed process 8734 (java) total-vm:5702824kB, anon-rss:908308kB, file-rss:0kB

### Problems with SSL certificates

Sometimes you can run into ssl connectivity issues. election-orchestra is configured to validate the ssl client certificate, and if that doesn't work then the HTTPS petition will not even reach to "eolog". This is because the client certificate validation happens directly in nginx. To see nginx log, we recommend using the following command:

    sudo tail -F /var/log/nginx/access.log

## Accepting and reviewing tasks in manual mode:

To list pending tasks

    $ sudo eotasks --list
	+----------+------------------+---------------+------------------------------------------+----------------------------+
	| small id |      label       |    election   |                sender_url                |        created_date        |
	+----------+------------------+---------------+------------------------------------------+----------------------------+
	| 0971e535 | approve_election | Test election | https://agoravoting-eovm:5000/api/queues | 2014-03-09 02:49:57.768612 |
	+----------+------------------+---------------+------------------------------------------+----------------------------+

The above example shows election creation task, as seen in the 'label' text. The following shows an election tally task:

	$ sudo eotasks --list
	+----------+------------------------+---------------+------------------------------------------+----------------------------+
	| small id |         label          |    election   |                sender_url                |        created_date        |
	+----------+------------------------+---------------+------------------------------------------+----------------------------+
	| d88dc9bc | approve_election_tally | Test election | https://agoravoting-eovm:5000/api/queues | 2014-03-09 03:04:20.590614 |
	+----------+------------------------+---------------+------------------------------------------+----------------------------+

To show more information about a task:

    $ sudo eotasks --show 0971e535
	+--------------+------------------------------------------+
	|   small id   |                 0971e535                 |
	|   election   |              Test election               |
	|    label     |             approve_election             |
	|  questions   |         Who Should be President?         |
	|  sender_url  | https://agoravoting-eovm:5000/api/queues |
	| created_date |        2014-03-09 02:49:57.768612        |
	+--------------+------------------------------------------+

To approve it:

    $ sudo eotasks --accept 0971e535

To reject it:

    $ sudo eotasks --reject 0971e535

To show full debugging information about a task:

	$ sudo eotasks --show-full 0971e535

	... a lot of text here ..
