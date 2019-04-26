#!/bin/sh
########################################################
# 環境構築用シェル
# ruby 2.6
# rails 5.2.2
# 作成者  fukuda
# 更新日  2018/03/20
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
install "mecab" mecab mecab-devel mecab-ipadic
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
