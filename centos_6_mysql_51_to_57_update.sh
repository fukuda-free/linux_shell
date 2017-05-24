#!/bin/bash

cat /etc/centos-release
mysql --version

service mysqld stop
yum remove -y mysql*
yum -y install http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
yum-config-manager --disable mysql55-community
yum-config-manager --enable mysql56-community
yum install -y mysql mysql-devel mysql-server mysql-utilities
service mysqld start
mysql_upgrade -u root
mysql --version

service mysqld stop
yum remove -y mysql*
yum -y install http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
yum-config-manager --disable mysql56-community
yum-config-manager --enable mysql57-community-dmr
yum install -y mysql mysql-devel mysql-server mysql-utilities

echo 'character-set-server=utf8mb4' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '[client]' >> /etc/my.cnf
echo 'default-character-set=utf8mb4' >> /etc/my.cnf

service mysqld start
mysql_upgrade -u root
service mysqld restart
mysql --version

echo "今から投入済みのデータの文字コードを変更します"
mysql -e "show databases" >> database_list.text

cat database_list.text | while read line
do
  if [ "$line" = "Database" -o "$line" = "information_schema" -o "$line" = "mysql" -o "$line" = "performance_schema" -o "$line" = "sys" -o "$line" = "test" ]; then
    echo "$line font change no"
  else
    echo "$line font change utf8 => utf8mb4"
    mysql -e "alter database $line character set utf8mb4;"
    (mysql "$line" -e "show tables" --batch --skip-column-names | xargs -I{} echo 'alter table `'{}'` convert to character set utf8mb4;') > alters.sql
  fi
done


cat alters.sql | while read line
do
  echo "$line"
done

rm -rf database_list.text
rm -rf alters.sql

