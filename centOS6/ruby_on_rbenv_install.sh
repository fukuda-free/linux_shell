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
# rbenvのインストール
echoG "rbenv install"

# GIT_INSTALL(予備)
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

case "${1}" in
  "2.4" ) 
    ruby_version='2.4.6';;
  "2.5" ) 
    ruby_version='2.5.5';;
  "2.6" ) 
    ruby_version='2.6.3';;
  * ) 
    ruby_version='2.5.5';;
esac

echoG "ruby ${ruby_version} install"
rbenv install -v ${ruby_version}
rbenv rehash
rbenv global ${ruby_version}


echoY 'ruby のバージョンは以下となります'
ruby -v
