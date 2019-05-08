#!/bin/sh
########################################################
# MySQL 5.7 用シェル
########################################################

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

systemctl enable mysqld.service
systemctl start mysqld.service

echoG "現在のMYSQLのバージョンは、以下の通りです"
mysqld --version