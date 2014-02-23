# Election Orchestra Puppet

Puppet-vagrant setup for election orchestra


## Installation (vagrant)

### Install vagrant

* http://www.vagrantup.com

### Download the repository

* git clone https://github.com/agoraciudadana/election-orchestra-puppet.git

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

* sudo sh shell/apt.sh
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

* sudo restore_backup.sh <path/to/backup>

## Update installation

Sometimes you might need to update the system. You will probably have to download first the last updates from the election-orchestra-puppet directory with "git pull".

After that, what you will have to do is to create a backup (as explained previously), copy your backup somewhere safe, and then create a fresh election-orchestra-puppet installation and then restore there your backup.

## Automatic/manual modes

There are two mode for working in election-orchestra: automatic and manual. This has to do with the election-orchestra requests from other peers, which are of two types: either create election public keys, or perform a tally.

The automatic mode accepts requests from allowed peers without requesting a confirmation from the authority administrator. Automatic mode is good for testing and also for public election authorities.

Manual mode needs the confirmation from the election authority administrator. This is good for improved security, for example to be able to confirm by other means that the tally request is legit, or to check the request data itself. It's useful for important elections.

Note that the default mode in a deployment is automatic, and this can be changed in manifests/init.pp with the variable "auto_mode". You can also check its value with:

* sudo eoauto

Or change it:

* sudo eoauto true

But the best way to do it is change it in manifests/init.pp and then executing puppet again (and restarting eorchestra with "supervisorctl restart eorchestra").

## Execute a test tally

If you have at least one peer package installed (and the peer has your peer package installed too), you can test your setup manually using eotest. To do a complete test you can just do:

* sudo eotest full --vmnd --vcount 100

First we have to create the election, which will use yours as the director authority and all the other configured (the one that "eopeers --list" show) as performers:

* sudo eotest create

This command will output the id of the created election. Now you need to create the encrypted votes, for example 10.000 votes:

* sudo eotest encrypt <id> --vmnd --vcount 100

And finally perform the tally:

* sudo eotest tally <id>

## Watching the election-orchestra log

It's quite useful to look at the log live to see what's happening. You can do that this way (you can stop watching with <Ctrl>+<C>):

* sudo eolog

## Reset a tally

Sometimes there's some kind of problem with a tally, and you need to launch it again. In that case, you need to reset it frist. You can either list the tallied election starting with the last one:

* sudo reset-tally

And reset a tally of an election by election-id:

* sudo reset-tally <election-id>

## Troubleshooting

* Invalid socket address

Probably means there is an old instance of verificatum running. Running the following command should kill the processes:
    sudo supervisorctl restart eorchestra

* Verificatum hangs

Did you forget to use ip’s instead of hostnames in the base_settings.py?  if so, change the file and restart eorchestra:
    sudo supervisorctl restart eorchestra


## Accepting and reviewing tasks in manual mode:

To list pending tasks:

* sudo eotasks list

    +----------+-----------------------------------+---------------------------+-----------------+-----------+-----------+----------------------------+
    | small id |             sender_url            |           action          |      queue      | task_type |   status  |        created_date        |
    +----------+-----------------------------------+---------------------------+-----------------+-----------+-----------+----------------------------+
    | 86ba85d2 | https://127.0.0.1:5000/api/queues | frestq.virtual_empty_task | internal.frestq |  external | executing | 2013-09-29 11:55:09.424713 |
    | 76df2601 | https://127.0.0.1:5000/api/queues | frestq.virtual_empty_task | internal.frestq |  external | executing | 2013-09-29 11:27:59.563677 |
    +----------+-----------------------------------+---------------------------+-----------------+-----------+-----------+----------------------------+

To show information about a task:

* sudo eotasks show 86ba85d2
    * frestq.virtual_empty_task.internal.frestq - external (86ba85d2, finished)
    label: approve_election
    info_text:
    * URL: https://example.com/election/url
    * Title: New Directive Board
    * Description: election description
    * Voting period: 2013-12-06T18:17:14.457000 - 2013-12-09T18:17:14.457000
    * Question data: {
        "max": 1,
        "min": 0,
        "question": "Who Should be President?",
        "answers": [
            "Alice",
            "Bob"
        ],
        "tally_type": "ONE_CHOICE"
    }
    * Authorities: [
        {
            "session_id": "vota4",
            "ssl_cert": "-----BEGIN CERTIFICATE-----\nMIIDwTCCAqmgAwIBAgIJAJjjgNzBed6aMA0GCSqGSIb3DQEBBQUAMHcxCzAJBgNV\nBAYTAkVTMQ8wDQYDVQQIDAZNYWRyaWQxDzANBgNVBAcMBk1hZHJpZDETMBEGA1UE\nCgwKVGVzdCBBZ29yYTEPMA0GA1UEAwwGRlJFU1RRMSAwHgYJKoZIhvcNAQkBFhFl\nZHVsaXhAd2Fkb2JvLmNvbTAeFw0xMzA3MjIxNjA2NTdaFw0xNjA1MTExNjA2NTda\nMHcxCzAJBgNVBAYTAkVTMQ8wDQYDVQQIDAZNYWRyaWQxDzANBgNVBAcMBk1hZHJp\nZDETMBEGA1UECgwKVGVzdCBBZ29yYTEPMA0GA1UEAwwGRlJFU1RRMSAwHgYJKoZI\nhvcNAQkBFhFlZHVsaXhAd2Fkb2JvLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEP\nADCCAQoCggEBAMLzkBGTwH7FiA36SyjlmlV8kh+jZ//LP4PqJNJjc5SAJHGxbexI\nI2lzEFQbHMXBbHPM1NnLJitv0y8Gg9QWWBajqQeymu8O0Np7u1LG9JqNzRKIEDXk\n0SZgSoCld/cCTvtUgcT68CBE55af5EifjCI4fRf2229AiP7iibVsQ5dL/zyxLnEe\nGvuSrd+s8xyVp3pyhfHAlRe+ftATjJ3wBUGCmUr9d1lS9fQziCIYzeq9fWnwxCz/\ngp76930iUEIp7vYQzSfgbWSuQgrlrZUOIR/2+Rfk2Y1S6dE9NwjGtLp3kMOIeM9A\nclA/YyPUR47DX2yHxjIUz7jLT+li5Wrx7JUCAwEAAaNQME4wHQYDVR0OBBYEFOuX\nWa3ax+1lokcIZ39dvOp5tyzUMB8GA1UdIwQYMBaAFOuXWa3ax+1lokcIZ39dvOp5\ntyzUMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADggEBAD8F+JIJ8wm9Tb6d\nLQb4BJqG+Qp7SsmCrBmxj36E9NF5ydZFdpFzhBk+FPp0qmb7QD6zVkH5KT/opO7O\nioaJ72mJWYW8YIUIo3gKg/CRIzbOh6p0rUJIrUwntE1a/LunQ5Ig+WLQrzrJjziA\neYXkm5r/B8XE6TQ9UGWFpRcV7FBFhhN2IYBiV8yAdx40b+6jMi4H7BSflfoTWdDe\n2UjFu0kEsmzzdVBAeFErYelhEhuiZEf8OhGtfnBPq4F59zRClCb94J2+yfA1ssEx\n1fs90BmQt9y07D14+MW78P3nWAQqWs5uP15V6P1xT5MHQKJIH4LhC3yTWng3rLRy\nw6/a4eE=\n-----END CERTIFICATE-----",
            "id": 7,
            "orchestra_url": "https://127.0.0.1:5000/api/queues",
            "name": "Auth1"
        },
        {
            "session_id": "vota4",
            "ssl_cert": "-----BEGIN CERTIFICATE-----\nMIIDXTCCAkWgAwIBAgIJAKTjrEAw+lxWMA0GCSqGSIb3DQEBBQUAMEUxCzAJBgNV\nBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX\naWRnaXRzIFB0eSBMdGQwHhcNMTMwNzIyMTYwODM0WhcNMTYwNTExMTYwODM0WjBF\nMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50\nZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB\nCgKCAQEAvVH2LmO7309mX32l7tPgPWF4w2QitKnWwryJGAYoMz9HluGjoVDvK+mT\noHJFD1sdYBvG2bFPZHcj5+5V+OvVMUHb3OB0M+1tA+GBtjtLdyd3tjqYz15iBKEt\n3MTaJ+Eg2S/4CurUB7MRII+/i6MtzzuY+r5+dp9c9kruw0ztKDGONatkCWlsAON7\nacT3G1IJ6hDCsHjpi3KVub9bemLMLWLazzvhQiALs80rnlvKPAMJO5YaIZneGbS5\nLEiskygTx4THftWSis1nNrwdoWJKrj35fINIqRSMyhV8/2YbdKfjSC4SYrudT3Fw\nyEwnkuhu/yElr86/JnSN2zZlj+MjrwIDAQABo1AwTjAdBgNVHQ4EFgQUGUgho+tE\nwNXv9y0mMmufzZyu2XUwHwYDVR0jBBgwFoAUGUgho+tEwNXv9y0mMmufzZyu2XUw\nDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUFAAOCAQEAMzYhnT8Ii10UL1hE0meD\nr+l99bymvi5284TUy8yne3FFOl4By6prpXeBSI1hOc9T2ZNJcJE/mSwMa7WQDkBC\nMPlsU1o2Xr2ewl8es1ik0/oLLU2pzsnfxmQe5j97ALgscfvkn0QO6KDeKmdd1P5c\nsLcwgiRul1drdVpjf3yMYs21IUpyBgcjvp1I7MIbYgNbxE1g3V0vGMAhG2TN3lMS\nCW7G4KBUxyp/HaAUVzz5NWOkNJ+U894d1jFacPcxcxI1zdUzyijQ8mrJvX/FqXHg\nOzzWuEmfCQld1HBMLEmQgiG0Yf3AWPpko4qy3H3BIqBpXoKVRyOCHWUQIChHJibp\n1A==\n-----END CERTIFICATE-----",
            "id": 8,
            "orchestra_url": "https://127.0.0.1:5001/api/queues",
            "name": "Auth2"
        }
    ]

To approve it:

* sudo eotasks accept 86ba85d2

To reject it:

* sudo eotasks deny 86ba85d2

