#!/bin/sh
########################################################
# docker 用シェル
########################################################
# 基本のアップデート
yum update -y
yum upgrade -y

# 旧バージョンのアンインストール
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
# Docker のインストール
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker

# Docker の起動
systemctl start docker

# OS 起動時に Docker が自動起動
systemctl enable docker

echo '--------------------------------------'
echo 'docker のバージョンは以下となります'
docker --version
echo '--------------------------------------'


# docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo '--------------------------------------'
echo 'docker-compose のバージョンは以下となります'
docker-compose --version
echo '--------------------------------------'


# プロキシの設定
# 社内環境などで、Proxy 下のネットワークに Docker 環境を構築した場合、Proxy の設定をします。
# 詳細については、公式ガイド の情報を確認してください。
# {{{
# mkdir -p /etc/systemd/system/docker.service.d
# vi /etc/systemd/system/docker.service.d/http-proxy.conf
# }}}

# /etc/systemd/system/docker.service.d/http-proxy.conf
# {{{
# [Service]
# Environment="HTTP_PROXY=http://<user>:<pass>@<proxy_host>:<proxy_port>" "HTTPS_PROXY=http://<user>:<pass>@<proxy_host>:<proxy_port>" "NO_PROXY=localhost"
# }}}

# 上記実施後、設定内容をフラッシュして、Docker を再起動します。
# systemctl daemon-reload
# systemctl restart docker