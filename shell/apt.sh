#!/bin/bash

# for up to date version of nginx
# http://nginx.org/en/linux_packages.html#stable
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62

grep 'http://nginx.org/packages/debian/ wheezy nginx' /etc/apt/sources.list || echo 'deb http://nginx.org/packages/debian/ wheezy nginx' >> /etc/apt/sources.list

apt-get update
# http://stackoverflow.com/questions/13018626/add-apt-repository-not-found
apt-get -y install python-software-properties software-properties-common htop sudo aptitude git supervisor libfreetype6-dev
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
(md5sum /tmp/puppetlabs-release-wheezy.deb | grep 873f97e435c881f5a9d8749033187b73) || (echo "invalid hash for /tmp/puppetlabs-release-wheezy.deb" && exit 1)
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


echo "Installing supervisor 3.0r1-1.."
wget -qO /tmp/supervisor_3.0r1-1_all.deb http://ftp.br.debian.org/debian/pool/main/s/supervisor/supervisor_3.0r1-1_all.deb
cd /tmp
(md5sum supervisor_3.0r1-1_all.deb | grep c2e8b72bf8ba3d0b68f3ba14f9f6d15d) || (echo "invalid hash for supervisor_3.0r1-1_all.deb" && exit 1)
dpkg -i supervisor_3.0r1-1_all.deb
rm /tmp/supervisor_3.0r1-1_all.deb


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
