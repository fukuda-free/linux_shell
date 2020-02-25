#!/bin/sh
########################################################
# ngrok 用シェル
########################################################

yum install -y wget
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
sudo mv ngrok /usr/local/bin

echo '使用例'
echo '  既存のwebサイト（80ポート）を公開する場合'
echo '  コマンド：ngrok http 80'
