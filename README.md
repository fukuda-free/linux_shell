# shell
### シェルによる環境構築
```sh
yum install -y git
git clone https://gitlab.ai-q.biz/public-project/shell.git
cd shell/
. centos_6_setting.sh
```



# 開発パッケージ
wget https://raw.githubusercontent.com/fukuda-free/linux_shell/master/centOS6/develop_package_install.sh
. develop_package_install.sh

# mysql
wget https://raw.githubusercontent.com/fukuda-free/linux_shell/master/centOS6/develop_mysql57_install.sh
. develop_mysql57_install.sh

# ruby install(2.4 or 2.5 or 2.6)
wget https://raw.githubusercontent.com/fukuda-free/linux_shell/master/centOS6/ruby_on_rbenv_install.sh
. ruby_on_rbenv_install.sh 2.6

# rails insltall(4.2 or 5.1 or 5.2)
wget https://raw.githubusercontent.com/fukuda-free/linux_shell/master/centOS6/rails_install.sh
. rails_install.sh 5.2

# node install(8 or 9 or 10 or 11 or 12)
wget https://raw.githubusercontent.com/fukuda-free/linux_shell/master/centOS6/node_on_nvm_install.sh
. node_on_nvm_install.sh 12