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

echo '# nginxのversionをレスポンスヘッダに含めないように修正'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo 'server_tokens off;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo 'upstream ai_q_unicorn{'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  server unix:/var/www/rails/ai_q/tmp/sockets/unicorn.sock;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '}'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo 'server {'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  listen       80 backlog=20480;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  server_name  dev-staging.ai-q.biz;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  return 301 https://$host$request_uri;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '}'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo 'server {'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # listen       443 ssl http2 backlog=20480;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  listen       443 backlog=20480;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  server_name  dev-staging.ai-q.biz;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  #charset koi8-r;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  access_log /var/log/nginx/ai_q.log;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  ssl on;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  ssl_certificate ssl_cert/ai-q.biz.pem;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  ssl_certificate_key ssl_cert/ai-q.biz.key;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # IPアドレスをアクセス元にする'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_set_header Host               $host;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_set_header X-Forwarded_For    $proxy_add_x_forwarded_for; # クライアントの IP アドレス'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_set_header X-Forwarded-Host   $host; # オリジナルのホスト名。クライアントが Host リクエストヘッダで渡す。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_set_header X-Forwarded-Server $host; # プロキシサーバのホスト名'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_set_header X-Real-IP          $remote_addr;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_set_header X-Forwarded-Proto  https;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # iframeで表示できるようにする簡易な対処'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  add_header "P3P" "CP='UNI CUR OUR'";'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # add_header Strict-Transport-Security "max-age=1576800; includeSubdomains";'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # ssl_session_cache   shared:SSL:1m;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # ssl_session_timeout 5m;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # ssl_prefer_server_ciphers on;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # ファイルアップロードする際の容量上限設定'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  client_max_body_size 100m;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # server_names_hash_bucket_size 128;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  client_header_buffer_size 8k;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  large_client_header_buffers 4 8k;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # プロキシサーバの応答のバッファリングを有効(on)、無効(off)にします。デフォルトは、有効(on)です。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # バッファリングを有効(on)にした場合、高速な応答を実現するために、プロキシサーバの応答を読み込み、'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # proxy_buffer_size、proxy_buffersによって決まったバッファエリアに格納します。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_buffering       on;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # プロキシサーバのレスポンス用バッファサイズ(4k or 8k)を設定します。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # デフォルトは、proxy_buffersの１つのバッファサイズと同じです。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_buffer_size     64m;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # プロキシサーバの応答のバッファサイズ(4k or 8k)とその個数を設定します。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # デフォルトは、個数は 8 個で、バッファサイズはシステムに依存します。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_buffers         8 64m;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # キャッシュのパス、キャッシュパラメータを設定します。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # キャッシュされたデータはファイルに格納されています。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # プロキシされたURLのMD5ハッシュは、キャッシュエントリのキーとして使用され、'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # 応答の内容とメタデータのキャッシュのパスにファイル名としても使用されます。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # レベルのパラメータは、キャッシュ内のサブディレクトリレベル数を設定します。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # proxy_cache_path      /var/cache/nginx/domain1.com levels=1:2 keys_zone=cache_domain1.com:15m inactive=7d max_size=1000m;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # キャッシュのテンポラリパスを設定します。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # ここでもproxy_cache_pathと同じようにlevelを追加で指定することができます。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # しかし、一般的には使わないことが多いようです。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # proxy_temp_path       /var/cache/nginx/temp 1 2;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # 上位サーバ(upstream server)への接続のタイムアウト（秒）を設定します。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # 60（秒）がデフォルト値で、75（秒）以上は設定できません。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # ここでは、60（秒）を設定しています。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # proxy_connect_timeout 75;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_connect_timeout 3600;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # プロキシサーバの応答の読み取りタイムアウトを設定します。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # それは、nginxへの要求に対して応答を取得するためにどれくらい待つかを決定します。 60（秒）がデフォルト値です。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # ここでは、90（秒）と若干長めに設定しています。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # phpの処理などで応答までの最大となる時間を設定するのが良いとされています。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # proxy_read_timeout    150;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_read_timeout    3600;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # 上位サーバ(upstream server)へのリクエストの転送タイムアウト（秒）を設定します。 60（秒）がデフォルト値です。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # ここでは、60（秒）を設定しています。'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  # proxy_send_timeout    150;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  proxy_send_timeout    3600;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  location /uploads {'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '    root /var/www/rails/ai_q/public;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  }'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  location / {'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '    proxy_pass http://ai_q_unicorn;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  }'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  error_page  404              /404.html;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  location = /40x.html {'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '    root   /usr/share/nginx/html;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  }'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo ''  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  error_page   500 502 503 504  /50x.html;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  location = /50x.html {'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '    root   /usr/share/nginx/html;'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '  }'  >> /etc/nginx/conf.d/ssl_ai_q.conf
echo '}'  >> /etc/nginx/conf.d/ssl_ai_q.conf
cd /etc/nginx
git clone https://gitlab.ai-q.biz/watson/ssl_cert.git



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

echo '再起動した後、確認してください'
