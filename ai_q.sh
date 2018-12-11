#!/bin/sh
read -p "AIQ用シェルV2を実行します。エンターを押してください"

yum update -y

echo "(${LINENO})  >> スワップ領域を自動で割り当てます"
echo "現在のスワップ領域は以下の通りです"
free

SWAPFILENAME=/swap.img
MEMSIZE=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`

if [ $MEMSIZE -lt 2097152 ]; then
SIZE=$((MEMSIZE * 2))k
elif [ $MEMSIZE -lt 8388608 ]; then
SIZE=${MEMSIZE}k
elif [ $MEMSIZE -lt 67108864 ]; then
SIZE=$((MEMSIZE / 2))k
else
SIZE=4194304k
fi

fallocate -l $SIZE $SWAPFILENAME && mkswap $SWAPFILENAME && swapon $SWAPFILENAME

echo "スワップ領域を以下に設定しました"
free


echo "時間軸を日本にします"
date
# rm -rf /etc/localtime
# cp -rf /usr/share/zoneinfo/Japan /etc/localtime
sudo ln -sf /usr/share/zoneinfo/Japan /etc/localtime
date
read -p "エンターを押してください"


echo 'パッケージを最新にします。パスワードを聞かれることがあります。'
sudo -v
sudo yum update -y
sudo yum install -y zlib
sudo yum install -y zlib-devel
sudo yum install -y openssl-devel
sudo yum install -y sqlite-devel
sudo yum install -y gcc-c++
sudo yum install -y glibc-headers
sudo yum install -y libyaml-devel
sudo yum install -y readline
sudo yum install -y readline-devel
sudo yum install -y libffi-devel
sudo yum install -y libxml2
sudo yum install -y libxml2-devel
sudo yum install -y libxslt
sudo yum install -y libxslt-devel
sudo yum install -y libyaml-devel
sudo yum install -y make
sudo yum -y install yum-cron


echo 'gitのバージョンを２に上げます'
sudo yum -y remove git
curl -s https://setup.ius.io/ | bash
yum install -y git2u
git clone git://git.kernel.org/pub/scm/git/git.git


echo 'rbenvのインストール'
git clone git://github.com/sstephenson/rbenv.git /usr/local/src/rbenv
echo 'export RBENV_ROOT="/usr/local/src/rbenv"' >> /etc/profile.d/rbenv.sh
echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
source /etc/profile.d/rbenv.sh
git clone git://github.com/sstephenson/ruby-build.git /usr/local/src/rbenv/plugins/ruby-build
ls /usr/local/src/rbenv/plugins/ruby-build/bin/


echo 'ruby(v2.4.5)のインストール'
rbenv install -v 2.4.5
rbenv rehash
rbenv global 2.4.5


echo 'rails のインストール'
gem install rack
gem install rails -v  4.2.10


echo 'nodeのインストール'
curl -sL https://rpm.nodesource.com/setup_9.x | bash -
yum install -y gcc-c++ make
yum install -y nodejs
yum -y install npm --enablerepo=epel
npm install -g yarn


echo 'git のバージョンは以下となります'
git --version
echo 'rbenv のバージョンは以下となります'
rbenv -v
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
read -p "エンターを押してください"


echo 'MySQL 5.7をインストール'
# 古いバージョンを削除
yum -y remove mysql*

# インストール
yum -y install https://dev.mysql.com/get/mysql57-community-release-el6-11.noarch.rpm
yum -y install mysql-community-server
yum -y install mysql-devel

echo '' >> /etc/my.cnf
echo 'skip-grant-tables' >> /etc/my.cnf
echo 'character-set-server=utf8mb4' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '[client]' >> /etc/my.cnf
echo 'default-character-set=utf8mb4' >> /etc/my.cnf
echo '' >> /etc/my.cnf
echo '' >> /etc/my.cnf
service mysqld restart
# バージョン確認
mysqld --version

DB_PASSWORD=$(grep "A temporary password is generated" /var/log/mysqld.log | sed -s 's/.*root@localhost: //')
echo "初期パスワードは、「${DB_PASSWORD}」です。"
echo "このパスワードは、場合によっては必要となりますので、"
echo "メモしておくことをお勧めします"
echo ""
read -p "エンターを押してください"



echo "yum からの mecab のインストール完了！"
sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm

sudo yum install -y mecab mecab-devel
sudo yum install -y mecab-ipadic
# 必要パッケージのインストール
sudo yum install -y git make curl xz


# 辞書の取得
WORKING=/tmp/mecabdic
mkdir -p $WORKING
cd $WORKING
git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git

# インストール
cd mecab-ipadic-neologd
./bin/install-mecab-ipadic-neologd -n
# yes
cd ~

echo 'mecab のバージョンは以下となります'
mecab --version

echo 'mecab の動作テスト'
echo 'すもももももももものうち' | mecab -d /usr/lib64/mecab/dic/mecab-ipadic-neologd

read -p "エンターを押してください"



echo ''
echo ''
echo 'AIQの設定'
echo ''
echo ''
yum install -y file-devel
yum install -y ImageMagick
mkdir /var/www
mkdir /var/www/rails
cd /var/www/rails
git clone http://gitlab.ai-q.biz/ai-q/ai_q.git
cd ai_q
mv ai_q_env ..

# ロードファイルの追記
echo ''                                        >> /root/.bashrc
echo '# AIQ setting file load'                 >> /root/.bashrc
echo 'if [ -f /var/www/rails/ai_q_env ]; then' >> /root/.bashrc
echo '  . /var/www/rails/ai_q_env'             >> /root/.bashrc
echo 'fi'                                      >> /root/.bashrc

echo ''
echo ''
echo 'AIQのgem設定'
echo ''
echo ''
bundle install --path vendor/bundle --jobs=4
# bundle exec gem uninstall okuribito_rails
# rm -rf config/okuribito.yml
RAILS_ENV=development bundle exec rake db:create
RAILS_ENV=development bundle exec rake db:migrate
bundle exec rails runner lib/console/share/recreate_common_db.rb
bundle exec rails runner lib/console/share/reload_sys_config_db_seed.rb
bundle exec rails runner lib/console/share/create_test_company.rb -c 5 -a 10 -u 10
bundle exec rake bower:install['--allow-root']

echo 'nginx のインストール'
sudo rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
sudo yum install -y nginx
chkconfig nginx on
nginx -v


echo '---------------------------------------------------------------------------------'
echo 'もし、可動しなかった場合、下記で表示されたパスを以下のコマンドで登録し、再インストールしてください'
sudo find / -name libmecab.so*
echo ''
echo 'コマンド①：echo "export MECAB_PATH=/usr/lib64/libmecab.so.2" >> ~/.bash_profile'
echo '                                    ------------------------'
echo '                                    ここを書き換えてください'
echo 'コマンド②：source ~/.bash_profile'
echo '---------------------------------------------------------------------------------'
echo ''
echo 'mecab-ipadic-neologd のインストール先は、以下の通りです'
echo `mecab-config --dicdir`"/mecab-ipadic-neologd"

read -p "エンターを押してください"

echo '- 以下の部分を環境に合わせて修正 ------------'
echo 'export MECAB_PATH=/usr/lib64/libmecab.so.2    ←  上記のフォルダと異なるなら設定が必要'
echo ''
echo '# AI-Qのホスト名  ←  変更'
echo 'export AIQ_HOSTNAME=192.168.30.106'
echo ''
echo '# データベースの設定  ←  変更'
echo 'export AIQ_DATABASE_HOSTNAME=localhost'
echo 'export AIQ_DATABASE_NAME_DEVELOPMENT=ai_q_development'
echo 'export AIQ_DATABASE_NAME_PRODUCTION=ai_q_production'
echo 'export AIQ_DATABASE_USERNAME=root'
echo 'export AIQ_DATABASE_PASSWORD='
echo '-------------'