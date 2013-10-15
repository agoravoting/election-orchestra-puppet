#!/bin/bash

EORCHESTRA_DIR=/home/eorchestra
VENV_DIR=$EORCHESTRA_DIR/venv

cd $EORCHESTRA_DIR 
git clone https://github.com/agoraciudadana/frestq
git clone https://github.com/agoraciudadana/election-orchestra
source $VENV_DIR/bin/activate
cd $EORCHESTRA_DIR/frestq
python setup.py install