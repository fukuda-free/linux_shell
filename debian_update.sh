#!/bin/sh

sudo apt-get update -y
sudo apt-get upgrade -y
sudo rpi-update -y
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo reboot
