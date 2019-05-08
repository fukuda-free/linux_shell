#!/bin/sh
########################################################
# 環境構築用シェル
# MySQL 5.7
# 作成者  fukuda
# 更新日  2019/03/13
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

# 古いバージョンを削除
yum -y remove mysql*

# インストール
yum -y install https://dev.mysql.com/get/mysql57-community-release-el6-11.noarch.rpm
yum -y install mysql-community-server
yum -y install mysql-devel

# バージョン確認
mysqld --version

# MYSQLの設定で、rootのパスワードを「なし」に
echo '' >> /etc/my.cnf
echo 'skip-grant-tables' >> /etc/my.cnf

# MYSQLの設定で、文字コードをutf8mb4に
echo 'character-set-server=utf8mb4' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '[client]' >> /etc/my.cnf
echo 'default-character-set=utf8mb4' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '' >> /etc/my.cnf

# 再起動
service mysqld restart

DB_PASSWORD=$(grep "A temporary password is generated" /var/log/mysqld.log | sed -s 's/.*root@localhost: //')
echoR "初期パスワードは、「${DB_PASSWORD}」です。"
echoR "このパスワードは、場合によっては必要となりますので、"
echoR "メモしておくことをお勧めします"
echo ""

chkconfig mysqld on

echoG "現在のMYSQLのバージョンは、以下の通りです"
mysqld --version