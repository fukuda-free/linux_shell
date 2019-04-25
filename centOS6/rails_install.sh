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
    rails_version='2.4.6';;
  "2.5" ) 
    rails_version='2.4.6';;
  "2.6" ) 
    rails_version='2.4.6';;
  * ) 
    rails_version='2.4.6';;
esac

echoG "rails ${rails_version} install"
RAILS_INSTALL ${rails_version}

echoY 'rails のバージョンは以下となります'
rails -v
