#!/bin/sh

# Raspbian のシステム更新
sudo apt update
sudo apt -yV upgrade
sudo apt -yV dist-upgrade
sudo rpi-update
sudo apt -yV autoremove
sudo apt autoclean


pip3 install numpy==1.13
sudo apt-get install -y libblas-dev liblapack-dev python3-dev libatlas-base-dev gfortran python3-setuptools
sudo pip3 install https://github.com/lhelontra/tensorflow-on-arm/releases/download/v1.4.1/tensorflow-1.4.1-cp35-none-linux_armv7l.whl
sudo apt-get install -y python3-h5py
sudo pip3 install keras==2.1.2
pip3 install -U numpy


git clone http://github.com/Movidius/ncsdk
cd ncsdk
make install && make examples


wget https://github.com/mt08xx/files/raw/master/opencv-rpi/libopencv3_3.4.0-20180115.1_armhf.deb
sudo apt install -y ./libopencv3_3.4.0-20180115.1_armhf.deb
sudo ldconfig