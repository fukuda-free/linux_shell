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

case "${1}" in
  "2.4" ) 
    node_version='2.4.6';;
  "2.5" ) 
    node_version='2.4.6';;
  "2.6" ) 
    node_version='2.4.6';;
  * ) 
    node_version='2.4.6';;
esac

echoG "node ${node_version} install"
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