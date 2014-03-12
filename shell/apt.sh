#!/bin/bash

# for up to date version of nginx
# http://danielmiessler.com/blog/upgrading-to-nginx-1-4-x-on-ubuntu#.UkyqAYYerA0
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62

grep 'http://nginx.org/packages/ubuntu/ precise nginx' /etc/apt/sources.list || echo 'deb http://nginx.org/packages/ubuntu/ precise nginx' >> /etc/apt/sources.list

apt-get update
# http://stackoverflow.com/questions/13018626/add-apt-repository-not-found
apt-get -y install python-software-properties software-properties-common htop sudo aptitude git
# java
# http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html
add-apt-repository -y ppa:webupd8team/java
apt-get -y install aptitude realpath

# puppet-python module
SCRIPT_PATH=$(readlink -f "$0")
cd $(dirname $SCRIPT_PATH)/../modules
if [ ! -d python ]
then
    git clone git://github.com/stankevich/puppet-python.git python
fi

wget -qO /tmp/puppetlabs-release-precise.deb https://apt.puppetlabs.com/puppetlabs-release-precise.deb

dpkg -i /tmp/puppetlabs-release-precise.deb
rm /tmp/puppetlabs-release-precise.deb

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
    /bin/echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
    /bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
    while ! apt-get install -y oracle-java7-installer
    do
        echo "Failed to download java, retrying in 10 seconds.."
        sleep 10
    done
fi
echo Java installed