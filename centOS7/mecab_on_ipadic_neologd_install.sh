#!/bin/sh
########################################################
# mecab 用シェル
########################################################

sudo yum update -y
# sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
# # sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.3.0-1.noarch.rpm
# # sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.4.0-1.noarch.rpm

# # タイムアウトする為、１次的にタイムアウト時間を変更
# echo '# 通信速度が遅いためtimeout時間を変更' >> /etc/yum.conf
# echo 'minrate=1' >> /etc/yum.conf
# echo 'timeout=500' >> /etc/yum.conf
# sudo yum install -y mecab mecab-ipadic mecab-jumandic mecab-devel

# if type mecab >/dev/null 2>&1; then
#   echo "yum からの mecab のインストール完了！"
# else
#   echo "yum からの mecab のインストールに失敗しました"
#   echo "その為、ソースからインストールします"
#   sudo yum install -y git make curl xz
#   sudo yum install -y gcc-c++
#   # yumによるインストールを失敗した場合
#   git clone https://github.com/taku910/mecab.git
#   cd mecab/mecab
#   ./configure --enable-utf8-only
#   make
#   sudo make install
# fi

# # # 後処理(元の状態に戻す)
# # sed -e '/# 通信速度が遅いためtimeout時間を変更/d' /etc/yum.conf
# # sed -e '/minrate=1/d' /etc/yum.conf
# # sed -i -e '/timeout=500/d' /etc/yum.conf

# echo 'mecab のバージョンは以下となります'
# mecab --version
# # echo 'mecab の動作検証'
# echo 'mecab の動作検証' -d /usr/lib64/mecab/dic/ipadic
# echo 'すもももももももものうち' | mecab

# echo 'mecab の動作検証' -d /usr/lib64/mecab/dic/jumandic
# echo 'すもももももももものうち' | mecab

# echo '決められた設定に沿ってインストールを行いますが、centOSの設定によっては失敗します'
# #path 登録
# echo 'export MECAB_PATH=/usr/lib64/libmecab.so.2' >> ~/.bash_profile
# source ~/.bash_profile
# sudo ./configure --with-charset=utf8

# # 必要パッケージのインストール
# sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
# sudo yum install -y mecab mecab-devel mecab-ipadic git make curl xz
# # sudo yum install -y mecab mecab-devel mecab-ipadic make curl xz
# # GIT_INSTALL

# git clone git://git.kernel.org/pub/scm/git/git.git

# # 辞書の取得
# WORKING=/tmp/mecabdic
# mkdir -p $WORKING
# cd $WORKING
# git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git

# # インストール
# cd mecab-ipadic-neologd
# ./bin/install-mecab-ipadic-neologd -n

# echo 'mecab のバージョンは以下となります'
# mecab --version

# echo 'mecab の動作テスト'
# echo 'すもももももももものうち' | mecab -d /usr/lib64/mecab/dic/mecab-ipadic-neologd

# echo '---------------------------------------------------------------------------------'
# echo 'もし、可動しなかった場合、下記で表示されたパスを以下のコマンドで登録し、再インストールしてください'
# sudo find / -name libmecab.so*
# echo ''
# echo 'コマンド①：echo "export MECAB_PATH=/usr/lib64/libmecab.so.2" >> ~/.bash_profile'
# echo '                                    ------------------------'
# echo '                                    ここを書き換えてください'
# echo 'コマンド②：source ~/.bash_profile'
# echo '---------------------------------------------------------------------------------'
# echo ''
# echo 'mecab-ipadic-neologd のインストール先は、以下の通りです'
# echo `mecab-config --dicdir`"/mecab-ipadic-neologd"




# mecab & ipadic-neologd
rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
sed -i -e '/^baseurl/d' /etc/yum.repos.d/groonga.repo
echo 'baseurl=http://packages.groonga.org/centos/7/$basearch/' >> /etc/yum.repos.d/groonga.repo

# yum makecache
sudo yum -y install "mecab" mecab mecab-devel mecab-ipadic
git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -y -n -a
sed -i -e '/^dicdir/c\dicdir = /usr/lib64/mecab/dic/mecab-ipadic-neologd' /etc/mecabrc

echo 'mecab のバージョンは以下となります'
mecab --version

echo 'mecab の動作テスト'
echo 'すもももももももものうち' | mecab -d /usr/lib64/mecab/dic/mecab-ipadic-neologd

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












# --------------------------------
# # vim install
# sudo yum -y install vim wget "ImageMagick" ImageMagick ImageMagick-devel

# # timezoneをAsia/Tokyoに変更
# sudo timedatectl set-timezone Asia/Tokyo

# # 開発パッケージ
# wget https://raw.githubusercontent.com/fukuda-free/linux_shell/master/centOS7/develop_package_install.sh
# . develop_package_install.sh

# # yum管理の各種ソフトウェアをアップデート
# sudo yum update -y

# # swap設定
# SWAPFILENAME=/swap.img
# MEMSIZE=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`

# if [ $MEMSIZE -lt 2097152 ]; then
#   SIZE=$((MEMSIZE * 2))k
# elif [ $MEMSIZE -lt 8388608 ]; then
#   SIZE=${MEMSIZE}k
# elif [ $MEMSIZE -lt 67108864 ]; then
#   SIZE=$((MEMSIZE / 2))k
# else
#   SIZE=4194304k
# fi

# fallocate -l $SIZE $SWAPFILENAME && mkswap $SWAPFILENAME && swapon $SWAPFILENAME

# echo "スワップ領域を以下に設定しました"
# free

# # mysql install(57 or 80)
# wget https://raw.githubusercontent.com/fukuda-free/linux_shell/master/centOS7/develop_mysql_install.sh
# . develop_mysql_install.sh 57


# # # mecab
# # wget https://raw.githubusercontent.com/fukuda-free/linux_shell/master/centOS7/mecab_on_ipadic_neologd_install.sh
# # . mecab_on_ipadic_neologd_install.sh

# # ruby install(2.4 or 2.5 or 2.6 or 自由)
# wget https://raw.githubusercontent.com/fukuda-free/linux_shell/master/centOS7/ruby_on_rbenv_install.sh
# . ruby_on_rbenv_install.sh 2.4
# gem install bundler

# # node install(8 or 9 or 10 or 11 or 12)
# wget https://raw.githubusercontent.com/fukuda-free/linux_shell/master/centOS7/node_on_nvm_install.sh
# . node_on_nvm_install.sh 9

# echo 'rails のインストール'
# gem install rack
# gem install rails -v  4.2.10

# echo '----------------------------------------------------'
# echo 'git のバージョンは以下となります'
# git --version
# echo 'rbenv のバージョンは以下となります'
# rbenv -v
# echo 'ruby のバージョンは以下となります'
# ruby -v
# echo 'rails のバージョンは以下となります'
# rails -v
# echo 'node.js のバージョンは以下となります'
# node -v
# echo 'npm のバージョンは以下となります'
# npm -v
# echo 'yarn のバージョンは以下となります'
# yarn -v
# echo 'MYSQL のバージョンは以下となります'
# mysqld --version
# echo '----------------------------------------------------'


# # mecab インストール

# ## インストール
# {{{
# # パターン１(コンパイル)
# yum install -y gcc-c++
# git clone https://github.com/taku910/mecab.git
# cd mecab/mecab
# ./configure  --enable-utf8-only
# make & make check
# make install

# # パターン２(コンパイル)
# # sudo yum install -y  bzip2 bzip2-devel gcc gcc-c++ git make wget curl openssl-devel readline-devel zlib-devel
# # sudo mkdir -p /tmp/install_mecab
# # cd /tmp/install_mecab
# # wget 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE' -O mecab-0.996.tar.gz
# # tar zxvf mecab-0.996.tar.gz && cd mecab-0.996 && ./configure --with-charset=utf8 --enable-utf8-only &&  make && sudo make install

# # パターン３（yum）
# sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
# sed -i -e '/^baseurl/d' /etc/yum.repos.d/groonga.repo
# echo 'baseurl=http://packages.groonga.org/centos/7/$basearch/' >> /etc/yum.repos.d/groonga.repo
# sudo yum install -y mecab mecab-devel mecab-ipadic
# }}}

# ## 確認
# {{{
# echo 'mecab のバージョンは以下となります'
# mecab -v
# echo 'mecab のパスは以下の通り'
# sudo find / -name libmecab.so*
# }}}

# # mecab-ipadic インストール
# # パターン１
# tar zxfv mecab-ipadic-2.7.0-20070801.tar.gz
# cd mecab-ipadic-2.7.0-20070801
# ./configure --with-charset=utf8
# make
# make install



# {{{
# sudo find /usr | grep mecab-config
# /usr/bin/mecab-config
# }}}