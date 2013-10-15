#!/bin/bash

EORCHESTRA_DIR=/home/eorchestra

cd $EORCHESTRA_DIR 
sudo -u eorchestra git clone https://github.com/agoraciudadana/verificatum
cd $EORCHESTRA_DIR/verificatum
sudo -u eorchestra ./configure
sudo -u eorchestra make
# fix wikstrom special o screwing things up
# http://stackoverflow.com/questions/361975/setting-the-default-java-character-encoding/623036#623036
# alternatively modify the makefile.am and makefile.in files
export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
make install
sudo -u eorchestra cp .verificatum_env /home/eorchestra
sudo -u eorchestra printf '\nsource /home/eorchestra/.verificatum_env' >> /home/eorchestra/.bashrc
source /home/eorchestra/.verificatum_env
vog -rndinit RandomDevice /dev/urandom