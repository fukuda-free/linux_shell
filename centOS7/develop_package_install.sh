#!/bin/sh
########################################################
# 開発用パッケージ 用シェル
########################################################

########################################################
echo "開発用パッケージをインストールします"
sudo yum update -y
yum -y groupinstall "Base" "Development tools" "Japanese Support"
yum -y install "development tools" gcc gdbm-devel libffi-devel
yum -y install  make glibc-headers openssl-devel readline libyaml-devel
yum -y install  readline-devel zlib zlib-devel bzip2-devel curl

echo "時間軸を日本にします"
timedatectl set-timezone Asia/Tokyo
sudo ln -sf /usr/share/zoneinfo/Japan /etc/localtime
date
sudo yum -y install ntp
sudo ntpdate ntp.nict.jp

# case "${1}" in
#     "ja" )
#       echo "LANG=\"ja_JP.UTF-8\"" > /etc/sysconfig/i18n
#       . /etc/sysconfig/i18n
# esac

echo 'git v2 install'
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum -y remove git git-\*
sudo yum -y install git2u

echo 'git のバージョンは以下となります'
git --version
echo ''
echo ''

echo 'swap拡張 (4G)'
sudo dd if=/dev/zero of=/Swapfile bs=1M count=4096
sudo chmod 600 /Swapfile
sudo mkswap /Swapfile
sudo swapon /Swapfile
sh -c "echo '/swapfile swap swap defaults 0 0' >> /etc/fstab"