#!/bin/bash

# for up to date version of nginx
# http://danielmiessler.com/blog/upgrading-to-nginx-1-4-x-on-ubuntu#.UkyqAYYerA0
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
echo 'deb http://nginx.org/packages/ubuntu/ precise nginx' >> /etc/apt/sources.list
echo 'deb-src http://nginx.org/packages/ubuntu/ precise nginx' >> /etc/apt/sources.list
apt-get update
# http://stackoverflow.com/questions/13018626/add-apt-repository-not-found
sudo apt-get -y install python-software-properties htop
# java
# http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html
add-apt-repository -y ppa:webupd8team/java

wget -qO /tmp/puppetlabs-release-precise.deb https://apt.puppetlabs.com/puppetlabs-release-precise.deb

dpkg -i /tmp/puppetlabs-release-precise.deb
rm /tmp/puppetlabs-release-precise.deb

aptitude update

echo Installing puppet
aptitude install -y puppet
echo "Puppet installed!"