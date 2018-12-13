#!/bin/sh
read -p "AIQ用シェルV2を実行します。エンターを押してください"

yum update -y

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
date
# rm -rf /etc/localtime
# cp -rf /usr/share/zoneinfo/Japan /etc/localtime
sudo ln -sf /usr/share/zoneinfo/Japan /etc/localtime
date
read -p "エンターを押してください"


echo 'パッケージを最新にします。パスワードを聞かれることがあります。'
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
sudo yum -y install yum-cron


echo 'gitのバージョンを２に上げます'
sudo yum -y remove git
curl -s https://setup.ius.io/ | bash
yum install -y git2u
git clone git://git.kernel.org/pub/scm/git/git.git


echo 'rbenvのインストール'
git clone git://github.com/sstephenson/rbenv.git /usr/local/src/rbenv
echo 'export RBENV_ROOT="/usr/local/src/rbenv"' >> /etc/profile.d/rbenv.sh
echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"'  >> /etc/profile.d/rbenv.sh
echo 'eval "$(rbenv init -)"'                   >> /etc/profile.d/rbenv.sh
source /etc/profile.d/rbenv.sh
git clone git://github.com/sstephenson/ruby-build.git /usr/local/src/rbenv/plugins/ruby-build
ls /usr/local/src/rbenv/plugins/ruby-build/bin/


echo 'ruby(v2.4.5)のインストール'
rbenv install -v 2.4.5
rbenv rehash
rbenv global 2.4.5


echo 'rails のインストール'
gem install rack
gem install rails -v  4.2.10


echo 'nodeのインストール'
curl -sL https://rpm.nodesource.com/setup_9.x | bash -
yum install -y gcc-c++ make
yum install -y nodejs
yum -y install npm --enablerepo=epel
npm install -g yarn


echo 'MySQL 5.7をインストール'
# 古いバージョンを削除
yum -y remove mysql*

# インストール
yum -y install https://dev.mysql.com/get/mysql57-community-release-el6-11.noarch.rpm
yum -y install mysql-community-server
yum -y install mysql-devel

echo ''                              >> /etc/my.cnf
echo 'skip-grant-tables'             >> /etc/my.cnf
echo 'character-set-server=utf8mb4'  >> /etc/my.cnf
echo ''                              >> /etc/my.cnf
echo ''                              >> /etc/my.cnf
echo ''                              >> /etc/my.cnf
echo '[client]'                      >> /etc/my.cnf
echo 'default-character-set=utf8mb4' >> /etc/my.cnf
echo ''                              >> /etc/my.cnf
echo ''                              >> /etc/my.cnf
service mysqld restart

DB_PASSWORD=$(grep "A temporary password is generated" /var/log/mysqld.log | sed -s 's/.*root@localhost: //')
echo "初期パスワードは、「${DB_PASSWORD}」です。"
echo "このパスワードは、場合によっては必要となりますので、"
echo "メモしておくことをお勧めします"
echo ""


echo 'git のバージョンは以下となります'
git --version
echo 'rbenv のバージョンは以下となります'
rbenv -v
echo 'ruby のバージョンは以下となります'
ruby -v
echo 'rails のバージョンは以下となります'
rails -v
echo 'node.js のバージョンは以下となります'
node -v
echo 'npm のバージョンは以下となります'
npm -v
echo 'yarn のバージョンは以下となります'
yarn -v
echo 'MYSQL のバージョンは以下となります'
mysqld --version
