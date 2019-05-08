#!/bin/sh
########################################################
# 開発 用シェル
########################################################

########################################################

echo "開発用パッケージをインストールします"
sudo -v
sudo yum update -y
sudo yum install -y zlib
sudo yum install -y zlib-devel
sudo yum install -y openssl-devel
sudo yum install -y sqlite-devel
sudo yum install -y gcc-c++
sudo yum install -y glibc-headers
sudo yum install -y libyaml-devel
sudo yum install -y readline
sudo yum install -y readline-devel
sudo yum install -y libffi-devel
sudo yum install -y libxml2
sudo yum install -y libxml2-devel
sudo yum install -y libxslt
sudo yum install -y libxslt-devel
sudo yum install -y libyaml-devel
sudo yum install -y make
sudo yum install -y yum-cron
sudo yum install -y curl
sudo yum install -y wget
sudo yum install -y git


echo "時間軸を日本にします"
sudo ln -sf /usr/share/zoneinfo/Japan /etc/localtime
date
sudo yum -y install ntp
sudo ntpdate ntp.nict.jp

echo 'git v2 install'
sudo yum -y remove git
curl -s https://setup.ius.io/ | bash
yum install -y git2u
git clone git://git.kernel.org/pub/scm/git/git.git

echo 'git のバージョンは以下となります'
git --version
echo ''
