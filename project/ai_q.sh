wget https://raw.githubusercontent.com/fukuda-free/linux_shell/develop/centOS6/develop_package_install.sh
. develop_package_install.sh

wget https://raw.githubusercontent.com/fukuda-free/linux_shell/develop/centOS6/develop_mysql57_install.sh
. develop_mysql57_install.sh

wget https://raw.githubusercontent.com/fukuda-free/linux_shell/develop/centOS6/ruby_on_rbenv_install.sh
. ruby_on_rbenv_install.sh 2.4

gem install rack
gem install sprockets -v 3.7.2
gem install rails -v 4.2.9

wget https://raw.githubusercontent.com/fukuda-free/linux_shell/develop/centOS6/node_on_nvm_install.sh
. node_on_nvm_install.sh 10

wget https://raw.githubusercontent.com/fukuda-free/linux_shell/develop/centOS6/mecab_on_ipadic_neologd_install.sh
. mecab_on_ipadic_neologd_install.sh

echo 'git のバージョンは以下となります'
git --version
echo 'ruby のバージョンは以下となります'
ruby -v
echo 'rails のバージョンは以下となります'
rails -v
echo 'node.js のバージョンは以下となります'
node -v
echo 'npm のバージョンは以下となります'
npm -v
echo 'yarn のバージョンは以下となります'
yarn -v
echo 'mecab のバージョンは以下となります'
mecab --version
echo "現在のMYSQLのバージョンは、以下の通りです"
sudo mysqld --version


