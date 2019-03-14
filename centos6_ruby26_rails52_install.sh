#!/bin/sh
########################################################
# 環境構築用シェル
# ruby 2.6
# rails 5.2.2
# 作成者  fukuda
# 更新日  2018/03/20
########################################################

########################################################
# メソッド群（TODO：基本弄らない）
########################################################
# rails instlal
RAILS_INSTALL(){
  gem install rack
  gem install rails -v  $1
}

# rbenvのインストール
RBENV_INSTALL(){
  # GIT_INSTALL
  yum install -y git

  git clone git://github.com/sstephenson/rbenv.git /usr/local/src/rbenv
  echo 'export RBENV_ROOT="/usr/local/src/rbenv"' >> /etc/profile.d/rbenv.sh
  echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
  source /etc/profile.d/rbenv.sh
  git clone git://github.com/sstephenson/ruby-build.git /usr/local/src/rbenv/plugins/ruby-build
  ls /usr/local/src/rbenv/plugins/ruby-build/bin/

  echoG 'rbenv のバージョンは以下となります'
  rbenv -v
}

  # 必要パッケージのインストール処理
DEVELOP_PACKAGE_INSTALL(){
  echoG 'パッケージを最新にします。パスワードを聞かれることがあります。'
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
}

# echoの装飾用
ESC="\e["
ESCEND=m
COLOR_OFF=${ESC}${ESCEND}

echoW() {
  # 文字色：Black Bold(灰色)
  echo -en "${ESC}37;5${ESCEND}"
  echo "${1}"
  echo -en "${COLOR_OFF}"
}
echoG() {
  # 文字色：green
  echo -en "${ESC}32;5${ESCEND}"
  echo "${1}" | tee -a ${LOG}
  echo -en "${COLOR_OFF}"
}
echoR() {
  # 文字色：Red
  echo -en "${ESC}31;5${ESCEND}"
  echo "${1}" | tee -a ${LOG}
  echo -en "${COLOR_OFF}"
}
echoY() {
  # 文字色：Yellow
  echo -en "${ESC}33;5${ESCEND}"
  echo "${1}" | tee -a ${LOG}
  echo -en "${COLOR_OFF}"
}
echoB() {
  # 文字色：Yellow
  echo -en "${ESC}36;5${ESCEND}"
  echo "${1}" | tee -a ${LOG}
  echo -en "${COLOR_OFF}"
}
########################################################

echoG "開発用パッケージをインストールします"
DEVELOP_PACKAGE_INSTALL

echoG "時間軸を日本にします"
sudo ln -sf /usr/share/zoneinfo/Japan /etc/localtime
date
sudo yum -y install ntp
sudo ntpdate ntp.nict.jp

echoG 'git 2 install'
sudo yum -y remove git
curl -s https://setup.ius.io/ | bash
yum install -y git2u
git clone git://git.kernel.org/pub/scm/git/git.git

echoG "rbenv install"
RBENV_INSTALL

echoG 'ruby 2.6.1 install'
rbenv install -v 2.6.1
rbenv rehash
rbenv global 2.6.1

echoG 'rails 5.2.2 install'
RAILS_INSTALL 5.2.2

echoG 'node 9 install'
curl -sL https://rpm.nodesource.com/setup_9.x | bash -
yum install -y gcc-c++ make
yum install -y nodejs
yum -y install npm --enablerepo=epel
npm install -g yarn


echoY 'git のバージョンは以下となります'
git --version
echoY 'ruby のバージョンは以下となります'
ruby -v
echoY 'rails のバージョンは以下となります'
rails -v
echoY 'node.js のバージョンは以下となります'
node -v
echoY 'npm のバージョンは以下となります'
npm -v
echoY 'yarn のバージョンは以下となります'
yarn -v