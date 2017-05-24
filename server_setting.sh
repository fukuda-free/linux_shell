#! /bin/sh
########################################################
# railsのディレクトリ
rails_dir="/var/www/rails/"
# rails_app名
app_name="ai_q"
# rails_appディレクトリ
rails_app_dir=$rails_dir$app_name

# env名
env_name="ai_q_env"
# rails_appディレクトリ
env_path=$rails_dir$env_name

refile_dir="tmp/uploads"
refile_path=$rails_dir$refile_dir

backup_dir='s3'
backup_path=$rails_dir$backup_dir

s3_mount_shell_dir='lib/shell/functions'
s3_mount_shell_path=$rails_app_dir/$s3_mount_shell_dir

S3_BACKUP_NAME='/var/www/rails/s3'
S3_MOUNT_NAME='/var/www/rails/ai_q/tmp/uploads'
########################################################


########################################################
#  環境設定 メニュー項目画面
########################################################
SETTING_MENU()
{
	while true; do
		cat << EOF
+---------------------------+
| 【 server setting menu 】 |
+---------------------------+
| [1] ENVの確認             |
| [2] S3のマウント          |
| [3] S3の確認              |
| [4] unicornの確認         |
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

# [2] S3のマウント
SETTING_MENU_2(){
	echo "($LINENO)	>> S3のマウント"
	REFILE_S3_MOUNT
	BACKUP_S3_MOUNT
	return 0   #正常終了は戻り値が0
}

# [3] S3の確認
SETTING_MENU_3(){
	df -h
	return 0
}

# [4] unicornの確認
SETTING_MENU_4(){
	ps ax | grep unicorn
	return 0
}

# [5] delayedの確認
SETTING_MENU_5(){
	ps ax | grep delayed
	return 0
}


#######################################################
# 呼び出しメソッド
#######################################################
# envファイルの確認
VIEW_ENV(){
	echo "($LINENO)	>> ENVファイルを表示します"
	less -e -N -X $env_path
}

BACKUP_S3_MOUNT(){
	#if [ -e $backup_path ]; then
	#	echo "$backup_path found."
	#	mv $backup_path $rails_dir/s3_bk
	#fi

	# bucket名読み込み
	source /var/www/rails/ai_q_env

	if [ -n "${AWS_S3_BUCKET}" ]; then
		${s3_mount_shell_path}/s3_mount.sh ${AWS_S3_BUCKET} ${S3_BACKUP_NAME}
		#mv -f $rails_dir/s3_bk $backup_path
	else
		echo "マウント可能なバケットが設定されていません"
		VIEW_ENV
	fi
}

REFILE_S3_MOUNT(){
	#if [ -e $refile_path ]; then
	#	echo "$refile_path found."
	#	mv $refile_path $rails_app_dir/refile_bk
	#fi

	# bucket名読み込み
	source /var/www/rails/ai_q_env

	if [ -n "${AWS_S3_BUCKET}" ]; then
		${s3_mount_shell_path}/s3_mount.sh ${AWS_S3_BUCKET} ${S3_MOUNT_NAME}
		#mv -f $rails_app_dir/refile_bk $refile_path
	else
		echo "マウント可能なバケットが設定されていません"
		VIEW_ENV
	fi
}

########################################################
#   メイン
########################################################
SETTING_MENU      #関数TOP_MENUを呼ぶ
