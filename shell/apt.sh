#!/bin/bash

# for up to date version of nginx
# http://nginx.org/en/linux_packages.html#stable
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62

grep 'http://nginx.org/packages/debian/ wheezy nginx' /etc/apt/sources.list || echo 'deb http://nginx.org/packages/debian/ wheezy nginx' >> /etc/apt/sources.list

apt-get update
# http://stackoverflow.com/questions/13018626/add-apt-repository-not-found
apt-get -y install python-software-properties software-properties-common htop sudo aptitude git
# java
# http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html
grep 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' /etc/apt/sources.list || echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
apt-get -y --force-yes install aptitude realpath

# puppet-python module
SCRIPT_PATH=$(readlink -f "$0")
cd $(dirname $SCRIPT_PATH)/../modules
if [ ! -d python ]
then
    git clone git://github.com/stankevich/puppet-python.git python
fi

wget -qO /tmp/puppetlabs-release-wheezy.deb https://apt.puppetlabs.com/puppetlabs-release-wheezy.deb

dpkg -i /tmp/puppetlabs-release-wheezy.deb
rm /tmp/puppetlabs-release-wheezy.deb

echo "saving path to manifests/init.pp so that backup script knows.."

SCRIPT_PATH=$(readlink -f "$0")
INIT_PATH=$(dirname $SCRIPT_PATH)/../manifests/init.pp
INIT_PATH=$(realpath $INIT_PATH)

echo "$INIT_PATH" > /root/.eo_puppet_manifests_path

aptitude update

locale-gen en_GB.UTF-8
update-locale
update-locale LANG=en_GB.UTF-8 LC_ALL=en_GB.UTF-8

echo Installing puppet
aptitude install -y puppet
echo "Puppet installed!"

echo Installing java..
if [ ! -f /usr/bin/java ]
then
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
    while ! apt-get install -y --force-yes oracle-java8-installer
    do
        echo "Failed to download java, retrying in 10 seconds.."
        sleep 10
    done
    apt-get install --force-yes oracle-java8-set-default
fi
echo Java installed
