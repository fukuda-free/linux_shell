#!/bin/sh
########################################################
# MySQL 用シェル
########################################################

########################################################
# 古いバージョンを削除
sudo yum -y remove mariadb-libs
sudo yum -y remove mysql*
sudo rm -rf /var/lib/mysql/
sudo yum update -y

# バージョン設置
case "${1}" in
  "57" )
    mysql_version='57';;
  "80" )
    mysql_version='80';;
  * )
    mysql_version='57';;
esac

# リポジトリ設置
echo "msyql ${mysql_version} install"
case "${mysql_version}" in
  "57" )
    sudo yum localinstall -y http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm;;
  "80" )
    rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm;;
esac

# インストール
sudo yum -y install mysql-community-server
sudo yum -y install mysql-community-devel


# MSYQL 設定設置
case "${mysql_version}" in
  "57" )
    echo ''                                                        >> /etc/my.cnf
    echo '# デフォルトの文字セット（初期値：utf8mb4 >= 8.0.1）'    >> /etc/my.cnf
    echo 'character-set-server=utf8mb4'                            >> /etc/my.cnf
    echo ''                                                        >> /etc/my.cnf
    echo '# 権限スキップの設定'                                    >> /etc/my.cnf
    echo 'skip-grant-tables'                                       >> /etc/my.cnf
    echo ''                                                        >> /etc/my.cnf
    ;;
  "80" )
    echo ''                                                        >> /etc/my.cnf
    echo '# デフォルトの文字セット（初期値：utf8mb4 >= 8.0.1）'    >> /etc/my.cnf
    echo 'character-set-server=utf8mb4'                            >> /etc/my.cnf
    echo ''                                                        >> /etc/my.cnf
    echo '# 権限スキップの設定'                                    >> /etc/my.cnf
    echo 'skip-grant-tables'                                       >> /etc/my.cnf
    echo ''                                                        >> /etc/my.cnf
    echo '# 旧 MySQL (5.7) との互換性確保 => 以前の認証方式に変更' >> /etc/my.cnf
    echo 'default_authentication_plugin=mysql_native_password'     >> /etc/my.cnf
    echo 'explicit_defaults_for_timestamp = true'                  >> /etc/my.cnf
    echo 'max_connections = 10000'                                 >> /etc/my.cnf
    echo 'max_connect_errors = 10'                                 >> /etc/my.cnf
    echo ''                                                        >> /etc/my.cnf
    ;;
esac




systemctl start mysqld
systemctl enable mysqld
systemctl restart mysqld


echo '-------------------------------------------'
echo '現在のMYSQLのバージョンは、以下の通りです'
mysqld --version
echo '-------------------------------------------'