#! /bin/sh
########################################################
# railsのディレクトリ
rails_dir="/var/www/rails"
# rails_app名
app_name="watson_tool"
# rails_appディレクトリ
rails_app_dir="${rails_dir}/${app_name}"

# mysqlデータのバックアップ数
log_cnt_max=10
# mysqlデータのバックアップ先
mysql_bk_dr="/var/www/rails/mysql_bk"

# mysql development user
mysql_development_user="root"
# mysql development pass
mysql_development_pass=""

# mysql production user
mysql_production_user="root"
# mysql production pass
mysql_production_pass=""

# puma_pid
puma_pid="${rails_app_dir}/tmp/pids/puma.pid"


# AWS関係 ##################################
# env名
env_name="ai_q_env"
# rails_appディレクトリ
env_path=$rails_dir/$env_name

export MECAB_PATH=/usr/lib64/libmecab.so.2
########################################################
# カラー設定
F_ESC="\e["
F_ESCEND="m"
F_COLOR_R="${F_ESC}31${F_ESCEND}"  # 赤文字
F_COLOR_G="${F_ESC}32${F_ESCEND}"  # 緑文字
F_COLOR_Y="${F_ESC}33${F_ESCEND}"  # 黄文字
F_COLOR_B="${F_ESC}34${F_ESCEND}"  # 青文字

F_COLOR_R_B="${F_ESC}31;01${F_ESCEND}"  # 青文字
F_COLOR_Y_B="${F_ESC}33;01${F_ESCEND}"  # 青文字

F_COLOR_OFF="${F_ESC}${F_ESCEND}"

########################################################
# TOPメニュー
########################################################
TOP_MENU()
{
  while true; do
		echo -e "+---------------------------+"
		echo -e "| ${F_COLOR_Y_B}【 RAILS MENU   】${F_COLOR_OFF} ${F_COLOR_R_B}v 3.00${F_COLOR_OFF} |"
		echo -e "+---------------------------+"
		echo -e "| [1]  development modeへ   |"
		echo -e "| [2]  production modeへ    |"
		echo -e "| [3]  gem modeへ           |"
		echo -e "| [4]  検証 modeへ          |"
		echo -e "| [e]  シェルを終了         |"
		echo -e "+---------------------------+"

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
		"4")
			VERI_MENU
			break ;;
		"e")
			break ;;
		*) echo "($LINENO)	>> キーが違います。" ;;
		esac
		read -p "ENTERを押してください。" BLANK
	done
}

########################################################
#  DEV メニュー項目画面
########################################################
DEV_MENU()
{
  while true; do
    cat << EOF
+--------------------------------+
|    【 RAILS MENU dev_mode】    |
+--------------------------------+
| [1]  nginx + puma 停止         |OK
| [2]  nginx + puma 起動         |OK
| [3]  DB + テーブル 構築        |OK
| [4]  DB + テーブル 再構築      |OK
| [5]  キャッシュの削除          |
| [6]  ルートファイルの確認      |
| [7]  bundle install 実行       |OK
| [8]  bundle install 再実行     |OK
| [9]  rails console 実行        |
| [e]  シェルを終了              |OK
+--------------------------------+
EOF

	read -p "項目を選択してください >>" KEY  #入力された項目を読み込み、変数KEYに代入する
	case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
		"1") DEV_ACTION ;;
		"2") DEV_ACTION ;;
		"3") DEV_ACTION ;;
		"4") DEV_ACTION ;;
		"5") DEV_ACTION ;;
		"6") DEV_ACTION ;;
		"7") DEV_ACTION ;;
		"8") DEV_ACTION ;;
		"9") DEV_ACTION ;;
		"e") break ;;
		*) echo "($LINENO)	>> キーが違います。" ;;
		esac
		read -p "ENTERを押してください。" BLANK
	done
}

# DEV_ACTION 共通メソッド
DEV_ACTION(){
	DEV_MENU_${KEY}
	if [ $? != 0 ]; then
		echo "($LINENO)	>> DEV_MENU_${KEY}で異常が発生しました"
	fi
}

#  [1]  nginx + puma 停止
DEV_MENU_1(){
	echo "($LINENO)	>> nginx + puma 停止"
	NGINX_STOP
	DEV_LOG_BK
	CACHE_CREAE
	return 0   #正常終了は戻り値が0
}

#  [2]  nginx + puma 起動
DEV_MENU_2(){
	echo "($LINENO)	>> nginx + puma 起動"
	NGINX_DEV_START
	return 0   #正常終了は戻り値が0
}

#  [3]  DB + テーブル 構築
DEV_MENU_3(){
	echo "($LINENO)	>> DB + テーブル 構築"
	DB_DEV_MIGRATE
	bundle exec annotate
	return 0
}

#  [4]  DB + テーブル 再構築
DEV_MENU_4(){
	echo "($LINENO)	>> [4]  DB + テーブル 再構築"

	# SQLバックアップ
	DEV_MYSQL_BK

	echo "($LINENO)	>> DB 再構築"
	 RAILS_ENV=development bundle exec rake db:drop

  # 開発DB作成
  DB_DEV_MIGRATE

  bundle exec annotate
	return 0
}

# [5]  キャッシュの削除
DEV_MENU_5(){
	echo "($LINENO)	>> キャッシュの削除を行ないます"
	DEV_LOG_BK
	CACHE_CREAE
	return 0
}

# [6]  ルートファイルの確認
DEV_MENU_6(){
	echo "($LINENO)	>> ルート を表示させます"
	bundle exec rake routes
	return 0
}

# [7]  bundle install 実行
DEV_MENU_7(){
	echo "($LINENO)	>> bundle install 実行します"
	# bundle exec bundle install --path vendor/bundle
	bundle install --path vendor/bundle --jobs=4
	return 0
}

# [8]  bundle install 再実行
DEV_MENU_8(){
	echo "($LINENO)	>> bundle install 再実行します"
	sudo rm -rf vendor/bundle
	# bundle exec bundle install --path vendor/bundle
	bundle install --path vendor/bundle --jobs=4
	return 0
}

# [9]  rails console 実行
DEV_MENU_9(){
	echo "($LINENO)	>> rails console 実行します"
	bundle exec rails console
	return 0
}


########################################################
#  PRO メニュー項目画面
########################################################
PRO_MENU()
{
  while true; do
    cat << EOF
+--------------------------------+
|    【 RAILS MENU PRO_mode】    |
+--------------------------------+
| [1]  nginx + puma 停止         |
| [2]  nginx + puma 起動         |
| [3]  DB + テーブル 構築        |
| [4]  キャッシュの削除          |
| [5]  コンパイル                |
| [6]  delayed_job の再起動      |
| [7]  rails console 実行        |
| [99] DB + テーブル 再構築      |
| [e]  シェルを終了              |
+--------------------------------+
EOF

	read -p "項目を選択してください >>" KEY  #入力された項目を読み込み、変数KEYに代入する
	case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
		"1")  PRO_ACTION ;;
		"2")  PRO_ACTION ;;
		"3")  PRO_ACTION ;;
		"4")  PRO_ACTION ;;
		"5")  PRO_ACTION ;;
		"6")  PRO_ACTION ;;
		"7")  PRO_ACTION ;;
		"99") PRO_ACTION ;;
		"e") break ;;
		*) echo "($LINENO)	>> キーが違います。" ;;
		esac
		read -p "ENTERを押してください。" BLANK
	done
}

# PRO_ACTION 共通メソッド
PRO_ACTION(){
	PRO_MENU_${KEY}
	if [ $? != 0 ]; then
		echo "($LINENO)	>> PRO_MENU_${KEY}で異常が発生しました"
	fi
}

#  [1]  nginx + puma 停止
PRO_MENU_1(){
	echo "($LINENO)	>> nginx + puma 停止"
	NGINX_STOP
	PRO_LOG_BK
	CACHE_CREAE
	return 0   #正常終了は戻り値が0
}

#  [2]  nginx + puma 起動
PRO_MENU_2(){
	echo "($LINENO)	>> nginx + puma 起動"
	NGINX_PRO_START
	return 0   #正常終了は戻り値が0
}

#  [3]  DB + テーブル 構築
PRO_MENU_3(){
	echo "($LINENO)	>> DB + テーブル 構築"
	DB_PRO_MIGRATE
	return 0
}

# [4]  キャッシュの削除
PRO_MENU_4(){
	echo "($LINENO)	>> キャッシュの削除を行ないます"
	PRO_LOG_BK
	CACHE_CREAE
	return 0
}

# [5]  コンパイル
PRO_MENU_5(){
	echo "($LINENO)	>> コンパイルを行ないます"
	PRO_LOG_BK
	CACHE_CREAE
	PRECOMPILE
	return 0
}

# [5]  delayed_job の再起動
PRO_MENU_6(){
	echo "($LINENO)	>> delayed_job(production)を再稼働します"
	DELAYED_JOB_PRO_RESTART
	return 0
}

# [7]  rails console 実行
PRO_MENU_7(){
	echo "($LINENO)	>> rails console 実行"
	RAILS_ENV=production bundle exec rails console
	return 0   #正常終了は戻り値が0
}

#  [4]  DB + テーブル 再構築
PRO_MENU_99(){
	echo "($LINENO)	>> [4]  DB + テーブル 再構築"

	# SQLバックアップ
	PRO_MYSQL_BK

	echo "($LINENO)	>> DB 再構築"
	RAILS_ENV=production bundle exec rake db:drop

  # 開発DB作成
  DB_PRO_MIGRATE

	return 0
}


#######################################################
# 呼び出しメソッド
#######################################################
# nginx 停止
NGINX_STOP(){
	echo "($LINENO)	>> Nginx 停止"
	service nginx stop

	echo "($LINENO)	>> puma 停止"
	# kill -QUIT `cat $puma_pid`
	pumactl -F config/puma.rb stop
}

# nginx 起動（開発環境）
NGINX_DEV_START(){
	# /etc/rc.d/init.d/httpd start
	echo "($LINENO)	>> puma 起動"
	# bundle exec puma_rails -c config/puma.rb -D
	# PORT=80 puma -C config/puma.rb -d
	puma -C config/puma.rb -d

	echo "($LINENO)	>> nginx 起動"
	service nginx start
}

# nginx 起動（開発環境）
NGINX_PRO_START(){
	export SECRET_KEY_BASE='bundle exec rake secret'

	echo "($LINENO)	>> puma 起動"
	bundle exec puma -E production -c config/puma.rb -D
	# SECRET_KEY_BASE=$(bundle exec rake secret) bundle exec puma -D -c config/puma.rb -E production

	echo "($LINENO)	>> nginx 起動"
	service nginx start
}

# 開発用ログをバックアップ
DEV_LOG_BK(){
	echo "($LINENO)	>> development ログ バックアップ"
	cp -p $rails_app_dir/log/development.log $rails_app_dir/log/development.log_$(date +%Y%m%d%H%M%S)

	# log_bk del ##########################
	all_file="*"

	cd $rails_dir/$app_name/log

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

	cd $rails_dir/$app_name

	echo "($LINENO)	>> ログ 初期化"
	bundle exec rake log:clear
}

# 本番用ログをバックアップ
PRO_LOG_BK(){
	echo "($LINENO)	>> production ログ バックアップ"
	cp -p $rails_app_dir/log/production.log $rails_app_dir/log/production.log_$(date +%Y%m%d%H%M%S)

	# log_bk del ##########################
	all_file="*"

	cd $rails_dir/$app_name/log

	# production
	rails_env_bk="production.log_"
	cnt=` ls $rails_app_dir/log/$rails_env_bk$all_file | wc -l`

	#ファイル数が設定値より大きいか比較
	if [ $cnt -gt $log_cnt_max ]; then
		echo "($LINENO)	>> production ログ バックアップ 過剰分削除"
		ls -tr $rails_app_dir/log/$rails_env_bk$all_file | head -$(($cnt-$log_cnt_max)) | xargs rm -f
	else
		echo "($LINENO)	>> production ログ バックアップ 保存"
	fi

	cd $rails_dir/$app_name

	echo "($LINENO)	>> ログ 初期化"
	bundle exec rake log:clear
}


# キャッシュクリア
CACHE_CREAE(){
	echo "($LINENO)	>> キャッシュ クリア"
	bundle exec rake tmp:clear
	bundle exec rails runner 'Rails.cache.clear'
}

# コンパイル
PRECOMPILE(){
	echo "($LINENO)	>> 古いコンパイルファイル 削除"
	rm -rf public/assets
	RAILS_ENV=production bundle exec rake assets:clean

	echo "($LINENO)	>> assets コンパイル 実行"
	RAILS_ENV=production bundle exec rake assets:precompile
}


# 開発環境DB、テーブル構築
DB_DEV_MIGRATE(){
	RAILS_ENV=development bundle exec rake db:create
	RAILS_ENV=development bundle exec rake db:migrate

	echo "($LINENO)	>> seedファイル 実行"
	bundle exec rake db:seed
}

# 本番環境DB＋テーブル構築
DB_PRO_MIGRATE(){
	RAILS_ENV=production bundle exec rake db:create
	RAILS_ENV=production bundle exec rake db:migrate

  echo "($LINENO)	>> seed用ymlファイル 削除（heart_seed）"
	rm -r -f $rails_app_dir/db/seeds/*.yml

	echo "($LINENO)	>> seed用ymlファイル 作成（heart_seed）"
	bundle exec rake heart_seed:xls

	echo "($LINENO)	>> seedファイル 実行"
	# bundle exec rake db:seed
	RAILS_ENV=production bundle exec rake db:seed
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

	cnt=` ls $mysql_bk_dr/$app_name/$rails_env$rails_env_bk$all_file | wc -l`

	echo "バックアップ数 = $cnt"
	echo "バックアップ設定数 = $log_cnt_max"

	#ファイル数が設定値より大きいか比較
	cd $mysql_bk_dr
	if [ $cnt -gt $log_cnt_max ]; then
		echo "($LINENO)	>> development_db 削除"
		ls -tr $mysql_bk_dr/$app_name/$rails_env$rails_env_bk$all_file | head -$(($cnt-$log_cnt_max)) | xargs rm -rf
	else
		echo "($LINENO)	>> development_db 保存"
	fi
	cd $rails_dir/$app_name
}

# 開発環境DBバックアップ
PRO_MYSQL_BK(){
	echo "($LINENO)	>> DBのバックアップファイルを構築します。"
	if [ -e ../mysql_bk ]; then
		# フォルダがある場合
		echo "($LINENO)	>> フォルダが存在します"
	else
		# フォルダがない場合
		mkdir ../mysql_bk
	fi

	# production ##########################
	rails_env="_production"
	rails_env_bk="_mysql_bk_"
	all_file="*"

	mysqldump --user=$mysql_production_user --password="$mysql_production_pass"  $app_name$rails_env > $mysql_bk_dr/$app_name$rails_env$rails_env_bk$(date +%Y%m%d%H%M%S).sql

	cnt=` ls $mysql_bk_dr/$app_name/$rails_env$rails_env_bk$all_file | wc -l`

	echo "バックアップ数 = $cnt"
	echo "バックアップ設定数 = $log_cnt_max"

	#ファイル数が設定値より大きいか比較
	cd $mysql_bk_dr
	if [ $cnt -gt $log_cnt_max ]; then
		echo "($LINENO)	>> development_db 削除"
		ls -tr $mysql_bk_dr/$app_name/$rails_env$rails_env_bk$all_file | head -$(($cnt-$log_cnt_max)) | xargs rm -rf
	else
		echo "($LINENO)	>> development_db 保存"
	fi
	cd $rails_dir/$app_name
}

########################################################
#  GEMメニュー項目画面
########################################################
GEM_MENU()
{
  while true; do
    cat << EOF
+--------------------------------+
|    【 RAILS MENU gem_mode】    |
+--------------------------------+
| [1] bower install              |
| [2] heart_seed setting         |
| [3] heart_seed create          |
| [4] delayed_job 再起動         |
| [5] 工事中                     |
| [6] 工事中                     |
| [7] 工事中                     |
| [8] 工事中                     |
| [9] 工事中                     |
| [e]  シェルを終了              |
+--------------------------------+
EOF

	read -p "項目を選択してください >>" KEY  #入力された項目を読み込み、変数KEYに代入する
	case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
		"1") GEM_ACTION ;;
		"2") GEM_ACTION ;;
		"3") GEM_ACTION ;;
		"4") GEM_ACTION ;;
		"e") break ;;
		*) echo "($LINENO)	>> キーが違います。" ;;
		esac
		read -p "ENTERを押してください。" BLANK
	done
}

# GEM_ACTION 共通メソッド
GEM_ACTION(){
	GEM_MENU_${KEY}
	if [ $? != 0 ]; then
		echo "($LINENO)	>> GEM_MENU_${KEY}で異常が発生しました"
	fi
}

GEM_MENU_1(){
  echo "($LINENO) >> bower install"
	BOWER_INSTALL
  return 0   #正常終了は戻り値が0
}

GEM_MENU_2(){
  echo "($LINENO) >> [2] heart_seed setting"
  HEART_SEED_SETTING
}

GEM_MENU_3(){
  echo "($LINENO) >> [3] heart_seed save"
  HEART_SEED_SAVE
}


GEM_MENU_4(){
  echo "($LINENO) >> [4] delayed_job 再起動"
	DELAYED_JOB_RESTART
}

# bower インストール
BOWER_INSTALL(){
  bundle exec rake bower:install['--allow-root']
}

HEART_SEED_SETTING(){
  bundle exec rake heart_seed:init
}

HEART_SEED_SAVE(){
  bundle exec rake heart_seed:xls
  # bundle exec rake heart_seed:db:seed
}

# bower インストール
BOWER_INSTALL(){
	echo "($LINENO)	>> bower install"
  bundle exec rake bower:install['--allow-root']
}

# rails_best_practices 実行
BEST_PRACTICES(){
	echo "($LINENO)	>> rails_best_practices 実行します"
	bundle exec rails_best_practices -f html .

	return 0   #正常終了は戻り値が0
}

# delayed_job 再起動
DELAYED_JOB_RESTART(){
	echo "($LINENO)	>> delayed_job 停止"
	bundle exec bin/delayed_job -n 1 stop

	echo "($LINENO)	>> delayed_job ジョブクリア"
	bundle exec rake jobs:clear

	echo "($LINENO)	>> delayed_job 起動"
	bundle exec bin/delayed_job -n 1 start

	# 諄いが、念の為に再起動
	# bundle exec RQaInCompanyLS_ENV=production bin/delayed_job -n 1 restart
	bundle exec bin/delayed_job -n 1 restart

	return 0   #正常終了は戻り値が0
}

DELAYED_JOB_PRO_RESTART(){
	echo "($LINENO)	>> delayed_job 停止"
        source ~/.bash_profile
	# bundle exec RAILS_ENV=production bin/delayed_job -n 1 stop
	RAILS_ENV=production bin/delayed_job -n 1 stop

	echo "($LINENO)	>> delayed_job ジョブクリア"
	RAILS_ENV=production bundle exec rake jobs:clear

	echo "($LINENO)	>> delayed_job 起動"
	# bundle exec RAILS_ENV=production bin/delayed_job -n 1 start
	RAILS_ENV=production bin/delayed_job -n 1 start

	# 諄いが、念の為に再起動
	# bundle exec RAILS_ENV=production bin/delayed_job -n 1 restart
	RAILS_ENV=production bin/delayed_job -n 1 restart
	return 0   #正常終了は戻り値が0
}

# i18n_generators 実行
I18N_GENERAT(){
	echo "($LINENO)	>> i18n_generators 実行"
	bundle exec rails g i18n ja

	return 0   #正常終了は戻り値が0
}

# whenever 実行
WHENEVER_RESTART(){
	echo "($LINENO)	>> whenever 削除"
	bundle exec whenever --clear-crontab
	echo "($LINENO)	>> whenever 登録"
	bundle exec whenever --update-crontab
}


########################################################
#  VERIメニュー項目画面(検証)
########################################################
VERI_MENU(){
	while true; do
		cat << EOF
+---------------------------+
| 【 server setting menu 】 |
+---------------------------+
| [1] ENVの確認             |
| [2] S3の確認              |
| [3] nginxの確認           |
| [4] pumaの確認         |
| [5] delayedの確認         |
| [e]  シェルを終了         |
+---------------------------+
EOF

	read -p "項目を選択してください >>" KEY  #入力された項目を読み込み、変数KEYに代入する
	case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
		"1") SETTING_ACTION ;;
		"2") SETTING_ACTION ;;
		"3") SETTING_ACTION ;;
		"4") SETTING_ACTION ;;
		"5") SETTING_ACTION ;;
		"e") break ;;
		*) echo "($LINENO)	>> キーが違います。" ;;
		esac
		read -p "ENTERを押してください。" BLANK
	done
}


# SETTING_ACTION 共通メソッド
SETTING_ACTION(){
	SETTING_MENU_${KEY}
	if [ $? != 0 ]; then
		echo "($LINENO)	>> SETTING_MENU_${KEY}で異常が発生しました"
	fi
}

# [1] ENVの確認
SETTING_MENU_1(){
	echo "($LINENO)	>> ai_q_envを確認"
	VIEW_ENV
	return 0   #正常終了は戻り値が0
}

# [2] S3の確認
SETTING_MENU_2(){
	df -h
	return 0
}

# [3] nginxの確認
SETTING_MENU_3(){
	ls -l /etc/nginx/conf.d
	read -p "Press [Enter] key to resume."

	PS3="中身を確認したいファイルの番号を選んでください :"
	select dir in /etc/nginx/conf.d/* ; do
		if [ -n "$dir" ]; then
			break
		fi
	done

	echo ${dir}のファイルを表示します
	cat ${dir}

	return 0
}

# [4] pumaの確認
SETTING_MENU_4(){
	ps ax | grep puma
	return 0
}

# [5] delayedの確認
SETTING_MENU_5(){
	ps ax | grep delayed
	return 0
}

# envファイルの確認
VIEW_ENV(){
	if [ -e $env_path ]; then
		echo "($LINENO)	>> ENVファイルを表示します"
		less -e -N -X $env_path
	else
		echo "($LINENO)	>> ENVファイルが存在しません"
	fi
}
########################################################
#   メイン
########################################################
TOP_MENU      #関数TOP_MENUを呼ぶ
