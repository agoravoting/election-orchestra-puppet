#!/bin/bash

# for up to date version of nginx
# http://nginx.org/en/linux_packages.html#stable
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 ABF5BD827BD9BF62

echo "Installing some dependencies.."
grep 'http://nginx.org/packages/ubuntu/ trusty nginx' /etc/apt/sources.list || (echo 'deb http://nginx.org/packages/ubuntu/ trusty nginx' >> /etc/apt/sources.list && wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key)
# java
# http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html
grep 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' /etc/apt/sources.list || echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list

apt-get update
# http://stackoverflow.com/questions/13018626/add-apt-repository-not-found
apt-get -y install python-software-properties software-properties-common htop git supervisor libfreetype6-dev puppet
apt-get -y --force-yes install aptitude realpath

# puppet-python module
echo "Downloading puppet-python repository.."
SCRIPT_PATH=$(realpath "$0")
pushd $(pwd)
cd $(dirname $SCRIPT_PATH)/../modules
if [ ! -d python ]
then
    git clone git://github.com/stankevich/puppet-python.git python
    cd python
    git checkout 0277b9c81f5838dce9353a0a87a7029b7ebcf397
fi
popd

echo "Saving path to manifests/init.pp so that backup script knows.."
INIT_PATH=$(dirname $SCRIPT_PATH)/../manifests/init.pp
INIT_PATH=$(realpath $INIT_PATH)
echo "$INIT_PATH" > /root/.eo_puppet_manifests_path

echo "setting locale.."
locale-gen en_GB.UTF-8
update-locale
update-locale LANG=en_GB.UTF-8 LC_ALL=en_GB.UTF-8

echo "Installing supervisor 3.0r1-1.."
[ -f supervisor_3.0r1-1_all.deb  ] || (wget -qO supervisor_3.0r1-1_all.deb http://launchpadlibrarian.net/173936425/supervisor_3.0r1-1_all.deb)
(md5sum supervisor_3.0r1-1_all.deb | grep 368bfa94087bdc5eca01eae1ecc87335) || (echo "invalid hash for supervisor_3.0r1-1_all.deb" && exit 1)
dpkg -i supervisor_3.0r1-1_all.deb
rm supervisor_3.0r1-1_all.deb


echo "Installing java.."
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
echo "Java installed"
