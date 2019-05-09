#!/bin/sh
########################################################
# MySQL 5.7 用シェル
########################################################

########################################################

# # 古いバージョンを削除
# sudo yum -y remove mysql*
# sudo yum -y remove mariadb-libs

# # インストール
# # sudo yum -y localinstall https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
# # sudo yum -y install mysql-community-server
# sudo yum -y installhttps://dev.mysql.com/get/mysql80-community-release-el7-2.noarch.rpm
# sudo yum-config-manager --disable mysql80-community
# sudo yum-config-manager --enable mysql57-community
# sudo yum -y install "mysql" mysql-community-server mysql-community-devel
# mysqld --version

# # バージョン確認
# mysqld --version

# # # MYSQLの設定で、rootのパスワードを「なし」に
# # echo '' >> /etc/my.cnf
# # echo 'skip-grant-tables' >> /etc/my.cnf

# # # MYSQLの設定で、文字コードをutf8mb4に
# # echo 'character-set-server=utf8mb4' >> /etc/my.cnf
# # echo '' >> /etc/my.cnf
# # echo '' >> /etc/my.cnf
# # echo '' >> /etc/my.cnf
# # echo '[client]' >> /etc/my.cnf
# # echo 'default-character-set=utf8mb4' >> /etc/my.cnf
# # echo '' >> /etc/my.cnf
# # echo '' >> /etc/my.cnf

# # 再起動
# service mysqld restart

# DB_PASSWORD=$(grep "A temporary password is generated" /var/log/mysqld.log | sed -s 's/.*root@localhost: //')
# echo "初期パスワードは、「${DB_PASSWORD}」です。"
# echo "このパスワードは、場合によっては必要となりますので、"
# echo "メモしておくことをお勧めします"
# echo ""

# sudo systemctl start mysqld.service
# sudo systemctl enable mysqld.service
# systemctl enable mysqld.service
# systemctl start mysqld.service

# echo "現在のMYSQLのバージョンは、以下の通りです"
# mysqld --version
# echo ''




# 事前準備
sudo yum -y remove mariadb-libs
sudo yum -y remove mysql*
sudo rm -rf /var/lib/mysql/

# MySQL 公式 yum リポジトリの追加
sudo yum -y localinstall http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm

# インストール
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

# 自動起動＋起動
sudo systemctl enable mysqld.service
sudo systemctl start mysqld.service

# バージョン確認
MYSQL_V=$(mysqld --version)
echo '-------------------------------------------'
echo '現在のMYSQLのバージョンは、以下の通りです'
mysqld --version
echo '-------------------------------------------'