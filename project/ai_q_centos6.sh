wget https://raw.githubusercontent.com/fukuda-free/linux_shell/develop/centOS6/develop_package_install.sh
. develop_package_install.sh

wget https://raw.githubusercontent.com/fukuda-free/linux_shell/develop/centOS6/develop_mysql57_install.sh
. develop_mysql57_install.sh

wget https://raw.githubusercontent.com/fukuda-free/linux_shell/develop/centOS6/ruby_on_rbenv_install.sh
. ruby_on_rbenv_install.sh 2.4

gem install rack
gem install sprockets -v 3.7.2
gem install rails -v 4.2.9
gem install foreman

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
echo ''


rm -rf develop_package_install.sh develop_mysql57_install.sh ruby_on_rbenv_install.sh  node_on_nvm_install.sh  mecab_on_ipadic_neologd_install.sh


echo 'aiqの準備を行います'
yum install -y file-devel
yum install -y ImageMagick
mkdir /var/www
mkdir /var/www/rails
cd /var/www/rails
git clone https://gitlab.ai-q.biz/ai-q/ai_q.git
cd ai_q
mv ai_q_env ..

# ロードファイルの追記
echo ''                                        >> /root/.bashrc
echo '# AIQ setting file load'                 >> /root/.bashrc
echo 'if [ -f /var/www/rails/ai_q_env ]; then' >> /root/.bashrc
echo '  . /var/www/rails/ai_q_env'             >> /root/.bashrc
echo 'fi'                                      >> /root/.bashrc

# 環境設定
echo '- mecabのパスは、下記の通り ------------'
sudo find / -name libmecab.so*
echo '- 以下の部分を環境に合わせて修正 ------------'
echo 'export MECAB_PATH=/usr/lib64/libmecab.so.2    ←  mecabの設定と異なるなら設定が必要'
echo ''
echo '# AI-Qのホスト名 '
echo 'export AIQ_HOSTNAME=192.168.30.106  ←  変更'
echo ''
echo '# データベースの設定  ←  必要に応じて変更'
echo 'export AIQ_DATABASE_HOSTNAME=localhost'
echo 'export AIQ_DATABASE_NAME_DEVELOPMENT=ai_q_development'
echo 'export AIQ_DATABASE_NAME_PRODUCTION=ai_q_production'
echo 'export AIQ_DATABASE_USERNAME=root'
echo 'export AIQ_DATABASE_PASSWORD='
echo '-------------'
echo '設定後、「. /var/www/rails/ai_q_env」を実行してください'
