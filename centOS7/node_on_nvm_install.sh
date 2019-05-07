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

# curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.bashrc
nvm install v${node_version}
nvm use v${node_version}
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