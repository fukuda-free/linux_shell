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

echo "(${LINENO})  >> スワップ領域を自動で割り当てます"
echo "現在のスワップ領域は以下の通りです"
free

SWAPFILENAME=/swap.img
MEMSIZE=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`

if [ $MEMSIZE -lt 2097152 ]; then
  SIZE=$((MEMSIZE * 2))k
elif [ $MEMSIZE -lt 8388608 ]; then
  SIZE=${MEMSIZE}k
elif [ $MEMSIZE -lt 67108864 ]; then
  SIZE=$((MEMSIZE / 2))k
else
  SIZE=4194304k
fi

fallocate -l $SIZE $SWAPFILENAME && mkswap $SWAPFILENAME && swapon $SWAPFILENAME

echo "スワップ領域を以下に設定しました"
free

echo "時間軸を日本にします"
sudo ln -sf /usr/share/zoneinfo/Japan /etc/localtime
date
sudo yum -y install ntp
sudo ntpdate ntp.nict.jp

echo 'git v2 install'
sudo yum -y remove git
yum install http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm
sudo yum install -y git

echo 'git のバージョンは以下となります'
git --version
echo ''


# echo 'anyenv install'
# git clone https://github.com/riywo/anyenv ~/.anyenv
# echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> .bashrc
# echo 'eval "$(anyenv init -)"' >> .bashrc
# exec $SHELL -l
# mkdir -p $(anyenv root)/plugins
# git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
# anyenv update

# echo 'anyenv のバージョンは以下となります'
# anyenv versions
# echo ''
