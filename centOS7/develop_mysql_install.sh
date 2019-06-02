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

case "${1}" in
  "57" )
    mysql_version='5.7';;
  "80" )
    mysql_version='8';;
  * )
    if [ -n "${1}" ]; then
      # 空で無ければ、それを利用
      mysql_version=${1}
    else
      # 空なら、2.5.5を利用
      mysql_version='8'
    fi
esac

echo "ruby ${mysql_version} install"
case "${mysql_version}" in
  "5.7" )
    mysql_version='5.7';;
  "8" )
    rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
    yum install -y mysql-community-devel
    yum install -y mysql-community-server

    echo '' >> /etc/my.cnf
    echo '# ログのタイムゾーンの設定（初期値：UTC）' >> /etc/my.cnf
    echo 'log_timestamps=SYSTEM' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '# クライアントの文字セットの設定を無視する' >> /etc/my.cnf
    echo 'skip-character-set-client-handshake' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '# デフォルトの文字セット（初期値：utf8mb4 >= 8.0.1）' >> /etc/my.cnf
    echo 'character-set-server=utf8mb4' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '# タイムスタンプのデフォルト値に関する設定（初期値：ON >= 8.0.2）' >> /etc/my.cnf
    echo 'explicit_defaults_for_timestamp=ON' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '# 権限スキップの設定' >> /etc/my.cnf
    echo 'skip-grant-tables' >> /etc/my.cnf

    systemctl start mysqld
    systemctl enable mysqld
    systemctl restart mysqld
esac

