# encoding: UTF-8
#########################################
#  rails 4.2 template        by fukuda  #
#                         version 1.01  #
#########################################

# >----------------------------[ method Setup ]------------------------------<
# ファイル書き込み用メソッド(追記)
def gem_replacement( file_name , berore_word , after_word)
  # 中身を読み込む
  f = File.open( file_name , "r" )
  buffer = f.read();

  # 中身を変換
  buffer.gsub!( berore_word , after_word );

  # ファイルに書き込む
  f = File.open( file_name , "w" )
  f.write(buffer)

  # ファイルを閉じる
  f.close()
end

# ファイル書き込み用メソッド(置換 - コメント化)
def gem_comment( file_name , gem_name )
  # 中身を読み込む
  f = File.open( file_name , "r" )
  buffer = f.read();

  # 中身を変換
  if gem_name
    buffer.gsub!( gem_name , "# #{gem_name}" );
  end

  # ファイルに書き込む
  f = File.open( file_name , "w" )
  f.write(buffer)

  # ファイルを閉じる
  f.close()
end

# 自分のIPアドレスを得る
require 'socket'
def my_address
  udp = UDPSocket.new
  # クラスBの先頭アドレス,echoポート 実際にはパケットは送信されない。
  udp.connect("128.0.0.0", 7)
  adrs = Socket.unpack_sockaddr_in(udp.getsockname)[1]
  udp.close
  adrs
end

def bundle_install
  run "bundle install --path vendor/bundle"
end

def config_app_setting
  %q{

    # Set timezone
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # 日本語化
    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :ja
    config.encoding = "utf-8"

    # generatorの設定
    config.generators do |g|
      g.orm :active_record
      g.template_engine :haml
      # g.test_framework :rspec, :fixture => true
      # g.fixture_replacement :factory_girl, :dir => "spec/factories"
      # g.view_specs false
      # g.controller_specs true
      # g.routing_specs false
      # g.helper_specs false
      # g.request_specs false
      g.assets false
      g.helper false
      g.stylesheets false
      g.javascripts false
    end

    # libファイルの自動読み込み
    # config.autoload_paths += %W(#{config.root}/lib)
    # config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # config.quiet_assets = false
    config.quiet_assets = true

  }
end

def config_development_setting( my_address )
  insert_into_file 'config/environments/development.rb' ,
  %(
  # メール設定
  config.action_mailer.default_url_options = { :host => "http://#{my_address}", :port => 80 }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address               => 'k-idea.jp',
    :port                  => 587,
    :openssl_verify_mode   => 'none',
    :authentication        => :plain,
    :user_name             => 'fukuda_test@k-idea.jp',
    :password              => '#ftest01',
    :enable_starttls_auto  => true,
  }

  # rack_dev_markの有効化
  # config.rack_dev_mark.enable = true
  # リボンの色と位置の指定
  # オプションの指定 position: 'right'で右上、 color: 'red'  でリボンを赤色に指定。(red green orange)
  # config.rack_dev_mark.theme = [:title, Rack::DevMark::Theme::GithubForkRibbon.new(position: 'left', fixed: true, color: 'red')]

  # Bulletの設定
  # config.after_initialize do
  #   Bullet.enable        = true # Bulletプラグインを有効
  #   Bullet.alert         = true # JavaScriptでの通知
  #   Bullet.bullet_logger = true # log/bullet.logへの出力
  #   Bullet.console       = true # ブラウザのコンソールログに記録
  #   Bullet.rails_logger  = true # Railsログに出力
  #   Bullet.add_footer    = true # 画面の下部に表示
  # end

  # 1Mを超えた際にdevelopment.0, development.1というファイルを作成し、
  # ５ファイルを超えた場合は古いファイルを削除
  config.logger = Logger.new("log/development.log", 5, 1 * 1024 * 1024)
  ), after: '# config.action_view.raise_on_missing_translations = true'
end

def config_production_setting( my_address )
  insert_into_file 'config/environments/production.rb' ,
  %(
  # Disable Rails's static asset server (Apache or nginx will already do this).
  # 静的ファイルの扱いをRailsで行うかどうかっていう設定です。
  # nginxで見つからないとunicornにいちいち問い合わせがいくのでサーバーの負荷が劇的にあがってしまう。
  # config.serve_static_assets = false
  config.serve_static_assets = true

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  # 下りgzにするため必須
  config.assets.compress = true

  # debug=trueにすると、application.css/jsと個別のファイルの二重読み込みがされます。
  config.assets.debug = false

  # メール設定
  config.action_mailer.default_url_options = { :host => "http://#{my_address}", :port => 80 }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address               => 'k-idea.jp',
    :port                  => 587,
    :openssl_verify_mode   => 'none',
    :authentication        => :plain,
    :user_name             => 'fukuda_test@k-idea.jp',
    :password              => '#ftest01',
    :enable_starttls_auto  => true,
  }
  ), after: 'config.active_record.dump_schema_after_migration = false'

end

def config_database_setting( app_name )
  run "cp config/database.yml config/database.yml_sample"
  run "rm -rf config/database.yml"

  file "config/database.yml" , <<-CODE
default: &default
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: root
  password:
  host: localhost

development:
  <<: *default
  database: #{@app_name}_development

production:
  <<: *default
  database: #{@app_name}_production
  username: root
  password:

test:
  <<: *default
  database: #{@app_name}_test
CODE
end

def gemfile_all_set
  %q{
# ココカラ 追加

# 画像/映像 関係
# gem 'rmagick', :require => 'RMagick'       # 画像を扱う
# gem 'mini_magick'                          # 画像のリサイズを行う
# gem 'carrierwave'                          # ファイルのアップロード
# gem 'carrierwave-magic'                    # carrierwaveで、content-type判定を可能に
# gem 'streamio-ffmpeg'                      # 動画を扱う
# gem 'file_validators'                      # file validate

# ビュー関係
# gem 'haml-rails'                                                       # Haml
# gem 'kaminari'                                                         # Pagenation 定番
# gem 'bootstrap-kaminari-views'                                         # kaminariにbootstrapを適応
# gem 'jquery-datatables-rails'                                          # datetable
# gem "nested_form"                                                      # フォームの動的追加
# gem 'bootstrap_form'                                                   # bootstrapの入力フォーム
# gem 'select2-rails'                                                    # オートコンプリート
# gem 'xdan-datetimepicker-rails'                                        # datetimepicker
# gem 'nprogress-rails'                                                  # プログレスバー
# gem 'spinjs-rails'                                                     # スピン。ロード中のグルグル出す奴
# gem 'ajaxspin'                                                         # スピン。ロード中のグルグル出す奴
# gem 'compass-rails', github: "Compass/compass-rails", branch: "master" # compass
# gem 'bootstrap-sass'                                                   # Bootstrap の sass版
# gem 'autoprefixer-rails'                                               # 自動でベンダープレフィックス
# gem 'bootstrap-sass-extras'                                            # bootstrap-sassに含まれていない機能を追加
# gem 'bootstrap3-rails'                                                 # Bootstrap
# gem 'bootstrap-material-design'                                        # マテリアルデザイン(bootstrap必須)
# gem 'bootswatch-rails'                                                 # Bootswatch
# gem 'rails-assets-bootstrap-fileinput', '~> 2.5.0'                     # fileinput
# gem 'devoops-rails'                                                    # devoopsデザイン（必要パッケージ全て）
# gem 'rails-assets-bootstrap', '3.1.0'                                  # devoopsデザイン（必要パッケージ全て）
# gem 'rails-assets-jquery', '2.1.0'                                     # devoopsデザイン（必要パッケージ全て）
# gem 'rails-assets-jquery-ui', '1.10.4'                                 # devoopsデザイン（必要パッケージ全て）
# gem 'bootstrap-datepicker-rails', '~> 1.3.0.1'
# gem 'rails-bootstrap-helpers'
# gem "font-awesome-rails"                                               # RailsにFont Awesomeを導入する
# gem 'adminlte2-rails'                                                  # adminlte2デザイン
# gem 'bower-rails'                                                      # bower
# gem 'record_with_operator'                                             # データを登録した人、更新した人の情報がほしい
# gem "rack-user_agent"                                                  # User-Agentに応じていろいろな判定
# gem "heart_seed"                                                       # seedデータをエクセルで作成

# 認証機能
# gem 'devise', '~> 3.4.0'                        # devise rails 4.2の場合は、こちら
# gem 'devise-bootstrap-views'                    # devise bootstrap導入
# gem 'devise-i18n'                               # devise 基礎文言 日本語化
# gem 'devise-i18n-views'                         # devise ログイン画面 日本語化
# gem 'enum_help'
# gem 'cancancan', '~> 1.10'

# gem 'ransack'                             # 検索
# gem 'fullcalendar-rails'                  # fullcalendar
# gem 'momentjs-rails'                      # fullcalendarとセットで
# gem 'ranked-model'                        # 表示順
# gem 'jquery-turbolinks'                   # jqueryのイベントがturbolinkのせいで発火しなくなる問題を解消するgem
# gem 'roo', '2.0.0beta1'                   # Excel, CSV, OpenOffice, GoogleSpreadSheetを開くことができるGem
# gem 'rubyXL'                              # Excel 出力で使用
# gem 'goldiloader'                         # 自動的にEager Loadingしてくれる
# gem 'friendly_id'                         # URLを人間や検索エンジンにわかりやすいようにする
# gem 'gon'                                 # javascriptsへの値渡し
# gem 'jQuery-Validation-Engine-rails'      # 入力チェック
# gem 'rubyzip'                             # zipファイルの作成




# gem "paranoia", "~> 2.0"                     # 論理削除
# gem 'paranoia_uniqueness_validator', '1.1.0' # 論理削除とセットで


# gem "sidekiq"                          # 並列処理
# gem 'delayed_job'                      # 並列処理
# gem 'delayed_job_active_record'        # delayed_jobとセットで
# gem 'daemons'                          # delayed_jobとセットで

# gem 'jc-validates_timeliness'               # 日付validate

# gem 'awesome_nested_set'                                    # モデルを階層構造に管理できるようにする
# gem "the_sortable_tree", "~> 2.5.0"                         # 階層構造を、jsで動かせるように(jstree-rails-4とセット)
# gem "jstree-rails-4"                                        # 階層構造を、jsで動かせるように
# gem 'jquery-ui-rails'                                       # jquery ui を導入
# gem "flutie"                                                # action , controller を表示
# gem 'action_args'                                           # paramsを省略。
# gem 'saikoro'                                               # ランダムを返す
# gem 'pretty_validation'                                     # validationファイルをフォルダ分けし、自動生成
# gem 'ajax_render'                                           # ajax実装を簡易化(rails3 以下のみ)
# gem 'pdf-reader'                                            # PDFファイル読込で便利
# gem 'activerecord-import'                                   # バルクインサート
# gem 'motorhead'                                             # 部分的機能をエンジン化
# gem 'rename'                                                # プロジェクト名を変更
# gem 'twitter-bootstrap-rails-confirm'                       # jsのポップアップをモーダル化
# gem 'data-confirm-modal', github: 'ifad/data-confirm-modal' # jsのポップアップをモーダル化
# gem 'Bootstrap-Image-Gallery-rails'                         # bootstrap Image Gallery
# gem 'bootstrap-slider-rails'                                # bootstrap slider
# gem 'apotomo'                                               # apotomo(cells 3) パーシャル分離用
# gem 'cells'                                                 # cells 4 パーシャル分離用
# gem 'cells', "~> 4.0.0"                                     # cells 4 パーシャル分離用
# gem 'cells-haml'                                            # cells 4 パーシャル分離用

# gem 'dotenv-rails'                                          # 環境変数を事前設定できる
# gem 'rest-client', '~> 1.8'                                 # REST をしやすく
# gem 'sunspot_rails'                                         # solr とアクセスする
# gem 'websocket-rails'                                       # Websocket を利用する為に必要


group :development do
  # gem 'guard'                              # ソースが変更した際に、指定のコマンドを実行する
  # gem 'guard-livereload', require: false   # ソースを修正するとブラウザが自動でロードする。ブラウザにアドオン必須
  # gem 'rails-erd'                          # rake-erdコマンドでActiveRecordからER図を作成できる
  # gem 'spring-commands-rspec'              # bin/rspecコマンドを使えるようにし、rspecの起動を早めれる
  # gem "rack-dev-mark"                      # 開発環境と本番環境を区別
  # gem 'annotate'                           # テーブル情報をモデルファイルに追記してくれる
  # gem 'erb2haml'                           # Converter erb => haml
  # gem 'quiet_assets'                       # アセットログの抑制
  # gem 'ryakuzu'                            # webから、マイグレーション

  # デバック
  # gem 'bullet'                             # N+1問題の検出
  # gem 'migration_comments'                 # マイグレーションにコメント追記をできる
  # gem 'custom_rails_logger'                # logファイル出力を整形
  # gem 'meta_request'                       # Chrome のデベロッパーツールにRailsタブが
  # gem "view_source_map"                    # development環境のHTMLに、パーシャルのパスをコメントとして出力する。

  # 保守的な
  # gem 'magic_encoding'                     # 無条件でUTF-8にエンコードコマンドを入力
  # gem 'rubocop', require: false            # コーディング規約の自動チェック
  # gem 'rails_best_practices'               # Railsのベストプラクティスを教えてくれる

  # Better Errors
  # gem 'better_errors'                    # 本体
  # gem 'binding_of_caller'                # Better Errors上でREPLを使用
  # gem 'did_you_mean'                     # スペルミス時に正しいのを教えてくれる(ruby 2.3以降は不要)
  gem 'rails-footnotes'                    # 表示に関係する情報をページの下に表示

  # その他
  # gem 'i18n_generators'                  # 辞書ファイル自動生成
end

group :development, :test do
  # Pry & extensions(デバッグなど便利)
  # gem 'pry-rails'                   # rails console(もしくは、rails c)でirbの代わりにpryを使われる
  # gem 'pry-doc'                     # methodを表示
  # gem 'pry-byebug'                  # デバッグを実施(Ruby 2.0以降で動作する)
  # gem 'pry-stack_explorer'          # スタックをたどれる
  # gem 'pry-coolline'
  # gem 'rb-readline'

  # 表示整形関連(ログなど見やすくなる)
  # gem 'hirb'                        # モデルの出力結果を表形式で表示する
  # gem 'hirb-unicode'                # hirbの日本語などマルチバイト文字の出力時の出力結果がすれる問題に対応
  # gem 'rails-flog', require: 'flog' # HashとSQLのログを見やすく整形
  # gem 'awesome_print'               # Rubyオブジェクトに色をつけて表示して見やすくなる

  # テスト関連
  # gem "rspec-rails"                 # rspec本体
  # gem "shoulda-matchers"            # モデルのテストを簡易にかけるmatcherが使える
  # gem "factory_girl_rails"          # テストデータ作成
  # gem "capybara"                    # エンドツーエンドテスト
  # gem "capybara-webkit"             # エンドツーエンドテスト(javascript含む)
  # gem 'launchy'                     # capybaraのsave_and_open_pageメソッドの実行時に画面を開いてくれる
  # gem "database_cleaner"            # エンドツーエンドテスト時のDBをクリーンにする
  # gem "test-queue"                  # テストを並列で実行する
  # gem 'faker'                       # 本物っぽいテストデータの作成
  # gem 'faker-japanese'              # 本物っぽいテストデータの作成（日本語対応）
  # gem 'database_rewinder'           # テスト環境のテーブルをきれいにする
  # gem 'timecop'                     # Time Mock
  # gem 'turnip'
  # gem 'captureful_formatter'
  # gem 'poltergeist'

  # Deploy
  # gem 'capistrano', '~> 3.2.1'
  # gem 'capistrano-rails'
  # gem 'capistrano-rbenv'
  # gem 'capistrano-bundler'
  # gem 'capistrano3-unicorn'
  # gem 'rails-flog', require: 'flog'
end

  }
end

def unicorn_setting
  %q{
# -*- coding: utf-8 -*-
# ワーカーの数
worker_processes 2
# timeout 30

# preload_app false
preload_app true

rails_root = File.expand_path('../../', __FILE__)
working_directory rails_root

# ソケット
listen "#{rails_root}/tmp/sockets/unicorn.sock"

# pid
pid "#{rails_root}/tmp/pids/unicorn.pid"

# ログ
stderr_path "#{rails_root}/log/unicorn_error.log"
stdout_path "#{rails_root}/log/unicorn.log"
  }
end

def nginx_setting( app_name , rails_dir , my_address )
  file "#{app_name}.conf" , <<-CODE
upstream #{app_name}_unicorn{
  server unix:#{rails_dir}/#{app_name}/tmp/sockets/unicorn.sock;
}

# ドメインを設定した後は、下記を変更
# server{
#   set $public_path /var/www/#{app_name}/public;
#   location /logo.jpg {
#     root $public_path;
#     access_log  off;
#   }
#   location ^.*{
#     return 404;
#   }
# }W

server {
  listen       80;
  # server_name  localhost;
  server_name  #{my_address};

  #charset koi8-r;
  access_log /var/log/nginx/#{app_name}.log;

  # IPアドレスをアクセス元にする
  proxy_set_header Host               $host;
  proxy_set_header X-Forwarded_For    $proxy_add_x_forwarded_for; # クライアントの IP アドレス
  proxy_set_header X-Forwarded-Host   $host; # オリジナルのホスト名。クライアントが Host リクエストヘッダで渡す。
  proxy_set_header X-Forwarded-Server $host; # プロキシサーバのホスト名
  proxy_set_header X-Real-IP          $remote_addr;

  # ファイルアップロードする際の容量上限設定
  client_max_body_size 20m;
  # server_names_hash_bucket_size 128;
  client_header_buffer_size 8k;
  large_client_header_buffers 4 8k;

  # プロキシサーバの応答のバッファリングを有効(on)、無効(off)にします。デフォルトは、有効(on)です。
  # バッファリングを有効(on)にした場合、高速な応答を実現するために、プロキシサーバの応答を読み込み、
  # proxy_buffer_size、proxy_buffersによって決まったバッファエリアに格納します。
  proxy_buffering       on;

  # プロキシサーバのレスポンス用バッファサイズ(4k or 8k)を設定します。
  # デフォルトは、proxy_buffersの１つのバッファサイズと同じです。
  proxy_buffer_size     64m;

  # プロキシサーバの応答のバッファサイズ(4k or 8k)とその個数を設定します。
  # デフォルトは、個数は 8 個で、バッファサイズはシステムに依存します。
  proxy_buffers         8 64m;

  # キャッシュのパス、キャッシュパラメータを設定します。
  # キャッシュされたデータはファイルに格納されています。
  # プロキシされたURLのMD5ハッシュは、キャッシュエントリのキーとして使用され、
  # 応答の内容とメタデータのキャッシュのパスにファイル名としても使用されます。
  # レベルのパラメータは、キャッシュ内のサブディレクトリレベル数を設定します。
  # proxy_cache_path      /var/cache/nginx/domain1.com levels=1:2 keys_zone=cache_domain1.com:15m inactive=7d max_size=1000m;

  # キャッシュのテンポラリパスを設定します。
  # ここでもproxy_cache_pathと同じようにlevelを追加で指定することができます。
  # しかし、一般的には使わないことが多いようです。
  # proxy_temp_path       /var/cache/nginx/temp 1 2;

  # 上位サーバ(upstream server)への接続のタイムアウト（秒）を設定します。
  # 60（秒）がデフォルト値で、75（秒）以上は設定できません。
  # ここでは、60（秒）を設定しています。
  proxy_connect_timeout 60;

  # プロキシサーバの応答の読み取りタイムアウトを設定します。
  # それは、nginxへの要求に対して応答を取得するためにどれくらい待つかを決定します。 60（秒）がデフォルト値です。
  # ここでは、90（秒）と若干長めに設定しています。
  # phpの処理などで応答までの最大となる時間を設定するのが良いとされています。
  proxy_read_timeout    90;

  # 上位サーバ(upstream server)へのリクエストの転送タイムアウト（秒）を設定します。 60（秒）がデフォルト値です。
  # ここでは、60（秒）を設定しています。
  proxy_send_timeout    60;

  location /uploads {
    root #{@rails_dir}/#{app_name}/public;
  }

  location / {
    proxy_pass http://#{app_name}_unicorn;
  }

  error_page  404              /404.html;
  location = /40x.html {
    root   /usr/share/nginx/html;
    # root #{rails_dir}/#{app_name}/public;
  }

  error_page   500 502 503 504  /50x.html;
  location = /50x.html {
    root   /usr/share/nginx/html;
    # root #{rails_dir}/#{app_name}/public;
  }
}
  CODE

end

# MySQL install
def linux_mysql_install
  if yes?('MYSQLの設定を行いますか？(y/n)')
    run 'yum -y install mysql-devel mysql-server'
    run 'yum info mysql-server'
    remove_file "/etc/my.cnf"

    file '/etc/my.cnf' ,
    %q{
    [mysql]
    default-character-set=utf8

    [mysqld]
    datadir=/var/lib/mysql
    socket=/var/lib/mysql/mysql.sock
    user=mysql
    symbolic-links=0
    skip-character-set-client-handshake
    character-set-server=utf8

    [mysqld_safe]
    log-error=/var/log/mysqld.log
    pid-file=/var/run/mysqld/mysqld.pid
    }

    run 'chkconfig mysqld on'
  end
  run "/etc/init.d/mysqld start"
end

# linux ローカル時間を日本時間に合わせる
def linux_time_setting
  run "mv /etc/localtime /etc/localtime.org"
  run "ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime"
end

def linux_ffmpeg_install

  file "ffmpeg_install.sh" , <<-CODE

# パッケージ
yum update -y
yum install autoconf automake cmake freetype-devel gcc gcc-c++ git libtool make mercurial nasm pkgconfig zlib-devel -y

# source code new directory to put all of the
mkdir ~/ffmpeg_sources

# Yasm
cd ~/ffmpeg_sources
git clone --depth 1 git://github.com/yasm/yasm.git
cd yasm
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install
make distclean

# libx264
cd ~/ffmpeg_sources
git clone --depth 1 git://git.videolan.org/x264
cd x264
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
make
make install
make distclean

# libx265
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make
make install

# libfdk_aac
cd ~/ffmpeg_sources
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
make distclean

# libmp3lame
cd ~/ffmpeg_sources
curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
make
make install
make distclean

# libopus
cd ~/ffmpeg_sources
git clone git://git.opus-codec.org/opus.git
cd opus
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
make distclean

# libogg
cd ~/ffmpeg_sources
curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
tar xzvf libogg-1.3.2.tar.gz
cd libogg-1.3.2
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
make distclean

# libvorbis
cd ~/ffmpeg_sources
curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
tar xzvf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
LDFLAGS="-L$HOME/ffmeg_build/lib" CPPFLAGS="-I$HOME/ffmpeg_build/include" ./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
make
make install
make distclean

# libvpx
cd ~/ffmpeg_sources
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="$HOME/ffmpeg_build" --disable-examples
make
make install
make clean

# FFmpeg
cd ~/ffmpeg_sources
git clone --depth 1 git://source.ffmpeg.org/ffmpeg
cd ffmpeg
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --pkg-config-flags="--static" --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265
make
make install
make distclean

ffmpeg -version
  CODE

  run "mv /var/www/rails/#{@app_name}/ffmpeg_install.sh /var/www/rails/ffmpeg_install.sh"
  run "sh /var/www/rails/ffmpeg_install.sh"
  run "rm -rf /var/www/rails/ffmpeg_install.sh"
end

def gem_haml_install
  gem_replacement("Gemfile" , "# gem 'haml-rails'" , "gem 'haml-rails'")
  gem_replacement("Gemfile" , "# gem 'erb2haml'"   , "gem 'erb2haml'")
  bundle_install
  run 'bundle exec rake haml:replace_erbs'
end

def gem_thml_template_select
  if yes?('erbのテンプレートを変更しますか？(y/n)')
  	puts '何を利用しますか？'
  	puts '> [1] haml'
  	# puts '> [2] slim'
  	html_template_num = ask "番号を入力してください:"

    case html_template_num
    when '1'
      gem_haml_install
    when '2'
    else
    end
  end
end

# >----------------------------[ title ]------------------------------<
@app_name  = app_name
@rails_dir = File.expand_path(File.dirname(__FILE__))
puts '+-------------------------------+'
puts '|  Rails Application Templates  |'
puts '|         creat_day 2016/01/05  |'
puts '+-------------------------------+'
puts " アプリ名： #{@app_name}"
puts " ディレクトリ： #{@rails_dir}"

run "sudo yum -y install git"
run "yum update -y"

# >----------------------------[ Initial Setup ]------------------------------<
remove_file "README.rdoc"
remove_file "public/index.html"

# application.rb
insert_into_file 'config/application.rb' ,
  config_app_setting ,
  after: 'config.active_record.raise_in_transactional_callbacks = true'

# DB config
config_database_setting( app_name )

# development
config_development_setting( my_address )

# production
config_production_setting( my_address )

# linux
linux_time_setting
linux_mysql_install

# >----------------------------[ gemfile Setup ]------------------------------<
# mysql2 & javaScript
gem_comment( "Gemfile" , "gem 'mysql2'" )
def gem_mysql2_version
  %q{
gem 'mysql2', '~> 0.3.20'
  }
end
insert_into_file 'Gemfile' ,
  gem_mysql2_version ,
  after: "# Use mysql as the database for Active Record"


gem_replacement(
  "Gemfile" ,
  "# gem 'therubyracer'" ,
  "gem 'therubyracer'"
)

# add_source "https://rails-assets.org"
append_file 'Gemfile', gemfile_all_set

# html template
gem_thml_template_select

# html template
if yes?('アプリケーションサーバーを使いますか？(y/n)')
	puts '何を利用しますか？'
	puts '> [1] unicorn'
	# puts '> [2] thin'
	app_server_num = ask "番号を入力してください"

  case app_server_num
  when '1'
  	# unicorn
    gem_replacement("Gemfile" , "# gem 'unicorn'" , "gem 'unicorn'")
    bundle_install

    # unicorn
    file 'config/unicorn.rb' , unicorn_setting
  when '2'
  else
  end
end

if yes?('nginxの設定を行いますか？(y/n)')
  nginx_setting( app_name , @rails_dir , my_address )
  run "sudo rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm"
  run "sudo yum -y install nginx"
  run "mv #{@app_name}.conf /etc/nginx/conf.d/#{@app_name}.conf"
end

# bower-rails
if yes?('bower-rails(javaScript管理) 使いますか？(y/n)')
	# gem 'bower-rails'
	gem_replacement("Gemfile" , "# gem 'bower-rails'" , "gem 'bower-rails'")

	run "rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm"
	run "yum -y install nodejs npm --enablerepo=epel"
	run "npm install -g bower"

	run "bundle install --path vendor/bundle"
	run "rails g bower_rails:initialize"
end

# carrierwave
if yes?('carrierwave(画像ファイル関係) 使いますか？(y/n)')
	gem_replacement("Gemfile" , "# gem 'rmagick'" , "gem 'rmagick'")
	gem_replacement("Gemfile" , "# gem 'mini_magick'" , "gem 'mini_magick'")
	gem_replacement("Gemfile" , "# gem 'carrierwave'" , "gem 'carrierwave'")

	run "sudo yum -y install ImageMagick ImageMagick-devel"
end

# streamio-ffmpeg
if yes?('ffmpeg(動画関係) 使いますか？(y/n)')
	gem_replacement("Gemfile" , "# gem 'streamio-ffmpeg'" , "gem 'streamio-ffmpeg'")
  linux_ffmpeg_install
	run "bundle install --path vendor/bundle"
end

# Kaminari config
if yes?('kaminari(ページネート)を 使いますか？(y/n)')
  gem_replacement("Gemfile" , "# gem 'kaminari'" , "gem 'kaminari'")
  gem_replacement("Gemfile" , "# gem 'bootstrap-kaminari-views'" , "gem 'bootstrap-kaminari-views'")
  bundle_install
  generate 'kaminari:config'
  generate 'kaminari:views bootstrap'
end

if yes?('heart_seed を 使いますか？(y/n)')
  gem_replacement("Gemfile" , "# gem 'heart_seed'" , "gem 'heart_seed'")
  bundle_install
  run 'bundle exec rake heart_seed:init'

  file 'config/heart_seed.yml' ,
  %q{
seed_dir: db/seeds
xls_dir: db/xls
catalogs:
  production:
  # - users
  # - user_profiles
  }
end




























































#---------------------------------------#
# デフォルトページ 作成
#---------------------------------------#
# i18n_generators
run 'rails g i18n_locale ja'

# rails-footnotes
run 'rails generate rails_footnotes:install'
run "magic_encoding"

# top_page_name = ask("トップページを準備します。コントローラー名を入力してください")
generate(:controller, "home index")
route "root :to => 'home#index'"

