#!/bin/sh
########################################################
# node シェル
# 作成者  fukuda
# 更新日  2018/05/07
########################################################

########################################################
case "${1}" in
  "8" )
    node_version='8.16.0';;
  "9" )
    node_version='9.11.2';;
  "10" )
    node_version='10.15.3';;
  "11" )
    node_version='11.14.0';;
  "12" )
    node_version='12.0.0';;
  * )
    node_version='12.0.0';;
esac

echo 'nodenv install'
# 対象物ダウンロード
git clone https://github.com/nodenv/nodenv.git ~/.nodenv
git clone https://github.com/nodenv/node-build.git ~/.nodenv/plugins/node-build
# パスを通す
echo 'export PATH="HOME/.nodenv/bin:HOME/.nodenv/bin:PATH"' >> ~/.bash_profile
echo 'eval "$(nodenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
# バージョン確認
nodenv -v

echo "${node_version} install"
nodenv install ${node_version}
nodenv global ${node_version}

yum install -y npm --enablerepo=epel
npm install -g yarn

echo 'node.js のバージョンは以下となります'
node -v
echo ''
echo 'npm のバージョンは以下となります'
npm -v
echo ''
echo 'yarn のバージョンは以下となります'
yarn -v
echo ''


