#! /bin/sh
########################################################
# railsのディレクトリ
rails_dir="/var/www/rails/"
# rails_app名
app_name=""
# rails_appディレクトリ
rails_app_dir=$rails_dir$app_name

# mysqlデータのバックアップ数
log_cnt_max=10
# mysqlデータのバックアップ先
mysql_bk_dr="/var/www/rails/mysql_bk/"

# mysql development user
mysql_development_user="root"
# mysql development pass
mysql_development_pass=""

# mysql production user
mysql_production_user="root"
# mysql production pass
mysql_production_pass=""

# unicorn_pid
unicorn_pid="$rails_app_dir/tmp/pids/unicorn.pid"
########################################################

########################################################
# TOPメニュー
TOP_MENU()
{
  while true; do
    cat << EOF
+--------------------------+
| 【 RAILS MENU   】 v 2.0 |
+--------------------------+
| [1]  development modeへ  |
| [2]  production modeへ   |
| [3]  gem modeへ          |
| [e]  シェルを終了        |
+--------------------------+
EOF

	read -p "項目を選択してください >>" TOP_NUMBER  #入力された項目を読み込み、変数TOP_NUMBERに代入する
	case "${TOP_NUMBER}" in  #変数KEYに合った内容でコマンドが実行される
		"1")
			DEV_MENU
			break ;;
		"2")
			PRO_MENU
			break ;;
		"3")
			GEM_MENU
			break ;;
		"e")
			break ;;
		*) echo "($LINENO)	>> キーが違います。" ;;
		esac
		read -p "ENTERを押してください。" BLANK
	done
}

########################################################
#  メニュー項目画面
########################################################
DEV_MENU()
{
  while true; do
    cat << EOF
+--------------------------------+
|    【 RAILS MENU dev_mode】    |
+--------------------------------+
| [1]  nginx + unicorn 停止      |
| [2]  nginx + unicorn 起動      |
| [3]  DB + テーブル 構築        |
| [4]  DB + テーブル 再構築      |
| [5]  キャッシュの削除          |
| [6]  ルートファイルの確認      |
| [7]  bundle install 実行       |
| [8]  bundle install 再実行     |
| [9]  rails console 実行        |
| [e]  シェルを終了              |
+--------------------------------+
EOF

	read -p "項目を選択してください >>" KEY  #入力された項目を読み込み、変数KEYに代入する
	case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
		"1") FNC_ACTION ;;
		"2") FNC_ACTION ;;
		"3") FNC_ACTION ;;
		"4") FNC_ACTION ;;
		"5") FNC_ACTION ;;
		"6") FNC_ACTION ;;
		"7") FNC_ACTION ;;
		"8") FNC_ACTION ;;
		"9") FNC_ACTION ;;
		"e") break ;;
		*) echo "($LINENO)	>> キーが違います。" ;;
		esac
		read -p "ENTERを押してください。" BLANK
	done
}

########################################################
# FNC_ACTION 共通メソッド
FNC_ACTION(){
	FNC_${KEY}
	if [ $? != 0 ]; then
		 echo "($LINENO)	>> FNC_${KEY}で異常が発生しました"
	fi
}

########################################################
#  [1]  nginx + unicorn 停止
FNC_1(){
	echo "($LINENO)	>> nginx + unicorn 停止"
	NGINX_STOP
	DEV_LOG_BK
	CACHE_CREAE
	return 0   #正常終了は戻り値が0
}

########################################################
#  [2]  nginx + unicorn 起動
FNC_2(){
	echo "($LINENO)	>> nginx + unicorn 起動"
	NGINX_DEV_START
	return 0   #正常終了は戻り値が0
}

########################################################
#  [3]  DB + テーブル 構築
FNC_3(){
	echo "($LINENO)	>> DB + テーブル 構築"
	DB_DEV_MIGRATE
	return 0
}

########################################################
#  [4]  DB + テーブル 再構築
FNC_4(){
	echo "($LINENO)	>> [4]  DB + テーブル 再構築"

	# SQLバックアップ
	DEV_MYSQL_BK

	echo "($LINENO)	>> DB 再構築"
	bundle exec rake db:drop:all

  # 開発DB作成
  DB_DEV_MIGRATE

	return 0
}

########################################################
# [5]  キャッシュの削除
FNC_5(){
	echo "($LINENO)	>> キャッシュの削除を行ないます"
	DEV_LOG_BK
	CACHE_CREAE
	return 0
}

########################################################
# [6]  ルートファイルの確認
FNC_6(){
	echo "($LINENO)	>> ルート を表示させます"
	bundle exec rake routes
	return 0
}

########################################################
# [7]  bundle install 実行
FNC_7(){
	echo "($LINENO)	>> bundle install 実行します"
	# bundle exec bundle install --path vendor/bundle
	bundle install --path vendor/bundle
	return 0
}

########################################################
# [8]  bundle install 再実行
FNC_8(){
	echo "($LINENO)	>> bundle install 再実行します"
	sudo rm -rf vendor/bundle
	# bundle exec bundle install --path vendor/bundle
	bundle install --path vendor/bundle
	return 0
}

########################################################
# [9]  rails console 実行
FNC_9(){
	echo "($LINENO)	>> rails console 実行します"
	bundle exec rails console
	return 0
}

 #######################################################
# 共通メソッド
# nginx 停止
NGINX_STOP(){
	echo "($LINENO)	>> Nginx 停止"
	 service nginx stop

	echo "($LINENO)	>> Unicorn 停止"
	 kill -QUIT `cat $unicorn_pid`
}

# nginx 起動（開発環境）
NGINX_DEV_START(){
	# /etc/rc.d/init.d/httpd start
	echo "($LINENO)	>> Unicorn 起動"
	bundle exec unicorn_rails -c config/unicorn.rb -D

	# unicorn単体用
	# bundle exec unicorn_rails -c config/unicorn.rb -p 8080 -D

	echo "($LINENO)	>> nginx 起動"
	 service nginx start
}

# nginx 起動（開発環境）
NGINX_PRO_START(){
	export SECRET_KEY_BASE='bundle exec rake secret'

	echo "($LINENO)	>> Unicorn 起動"
	# bundle exec unicorn -E production -c config/unicorn.rb -D
	SECRET_KEY_BASE=$(bundle exec rake secret) bundle exec unicorn -D -c config/unicorn.rb -E production

	echo "($LINENO)	>> nginx 起動"
	service nginx start
}

# 開発用ログをバックアップ
DEV_LOG_BK(){
	echo "($LINENO)	>> development ログ バックアップ"
	 cp -p $rails_app_dir/log/development.log $rails_app_dir/log/development.log_$(date +%Y%m%d%H%M%S)

	# log_bk del ##########################
	all_file="*"

	cd $rails_dir$app_name/log

	# development
	rails_env_bk="development.log_"
	cnt=` ls $rails_app_dir/log/$rails_env_bk$all_file | wc -l`

	#ファイル数が設定値より大きいか比較
	if [ $cnt -gt $log_cnt_max ]; then
		echo "($LINENO)	>> development ログ バックアップ 過剰分削除"
		 ls -tr $rails_app_dir/log/$rails_env_bk$all_file | head -$(($cnt-$log_cnt_max)) | xargs rm -f
	else
		echo "($LINENO)	>> development ログ バックアップ 保存"
	fi

	cd $rails_dir$app_name

	echo "($LINENO)	>> ログ 初期化"
	bundle exec rake log:clear
}

# 開発環境DB、テーブル構築
DB_DEV_MIGRATE(){
	bundle exec rake db:create:all
	bundle exec rake db:migrate

	echo "($LINENO)	>> seedファイル 実行"
	bundle exec rake db:seed
}

# キャッシュクリア
CACHE_CREAE(){
	echo "($LINENO)	>> キャッシュ クリア"
	bundle exec rake tmp:clear
}

# 開発環境のDBバックアップ
DEV_MYSQL_BK(){
	echo "($LINENO)	>> DBのバックアップファイルを構築します。"
	if [ -e ../mysql_bk ]; then
		# フォルダがある場合
		echo "($LINENO)	>> フォルダが存在します"
	else
		# フォルダがない場合
		mkdir ../mysql_bk
	fi

	# development ##########################
	rails_env="_development"
	rails_env_bk="_mysql_bk_"
	all_file="*"

	mysqldump --user=$mysql_development_user --password="$mysql_development_pass"  $app_name$rails_env > $mysql_bk_dr/$app_name$rails_env$rails_env_bk$(date +%Y%m%d%H%M%S).sql

	cnt=` ls $mysql_bk_dr/$app_name$rails_env$rails_env_bk$all_file | wc -l`

	echo "バックアップ数 = $cnt"
	echo "バックアップ設定数 = $log_cnt_max"

	#ファイル数が設定値より大きいか比較
	cd $mysql_bk_dr
	if [ $cnt -gt $log_cnt_max ]; then
		echo "($LINENO)	>> development_db 削除"
		ls -tr $mysql_bk_dr/$app_name$rails_env$rails_env_bk$all_file | head -$(($cnt-$log_cnt_max)) | xargs rm -rf
	else
		echo "($LINENO)	>> development_db 保存"
	fi
	cd $rails_dir$app_name
}

########################################################
#   メイン
########################################################
TOP_MENU      #関数TOP_MENUを呼ぶ
