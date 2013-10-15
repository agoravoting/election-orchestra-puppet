#!/bin/bash

# for up to date version of nginx
# http://danielmiessler.com/blog/upgrading-to-nginx-1-4-x-on-ubuntu#.UkyqAYYerA0
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
echo 'deb http://nginx.org/packages/ubuntu/ precise nginx' >> /etc/apt/sources.list
echo 'deb-src http://nginx.org/packages/ubuntu/ precise nginx' >> /etc/apt/sources.list
apt-get update
# http://stackoverflow.com/questions/13018626/add-apt-repository-not-found
sudo apt-get -y install python-software-properties
# java
# http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html
add-apt-repository -y ppa:webupd8team/java
apt-get update