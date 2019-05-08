#!/bin/sh
########################################################
# MySQL 5.7 用シェル
########################################################

########################################################

# 古いバージョンを削除
sudo yum -y remove mysql*
sudo yum -y remove mariadb-libs

# インストール
sudo yum -y localinstall https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
sudo yum -y install mysql-community-server

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
echo "初期パスワードは、「${DB_PASSWORD}」です。"
echo "このパスワードは、場合によっては必要となりますので、"
echo "メモしておくことをお勧めします"
echo ""

sudo systemctl start mysqld.service
sudo systemctl enable mysqld.service

echo "現在のMYSQLのバージョンは、以下の通りです"
mysqld --version