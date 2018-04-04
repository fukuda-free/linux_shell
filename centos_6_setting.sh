#!/bin/sh
########################################################
# Ruby On Rails 環境構築用シェル
# 作成者  fukuda
# 更新日  2018/03/20
########################################################

# echoの装飾用
ESC="\e["
ESCEND=m
COLOR_OFF=${ESC}${ESCEND}

echoComment() {
  # 文字色：Black Bold(灰色)
  echo -en "${ESC}30;1${ESCEND}"
  echo "${1}"
  echo -en "${COLOR_OFF}"
}
echoGreen() {
  # 文字色：green
  echo -en "${ESC}32${ESCEND}"
  echo "${1}" | tee -a ${LOG}
  echo -en "${COLOR_OFF}"
}
echoRed() {
  # 文字色：Red
  echo -en "${ESC}31${ESCEND}"
  echo "${1}" | tee -a ${LOG}
  echo -en "${COLOR_OFF}"
}
echoYellow() {
  # 文字色：Yellow
  echo -en "${ESC}33${ESCEND}"
  echo "${1}" | tee -a ${LOG}
  echo -en "${COLOR_OFF}"
}


########################################################
#  メニュー項目画面
FNC_MENU(){
  while true; do
    cat << EOF
+------------------------------------------+
|                【 MENU 】          v 5.3 |
+------------------------------------------+
| [ 1]  開発用としてiptableとselinuxを解除 |
| [ 2]  ruby をインストール                |
| [ 3]  rails をインストール               |
| [ 4]  node.js をインストール             |
| [ 5]  MYSQL 5.7 をインストール           |
| [ 6]  スワップ領域の割り当て             |
| [ 7]  ffmpeg（のみ） をインストール      |
| [ 8]  ImageMagick をインストール         |
| [ 9]  mecab をインストール               |（検証中）
| [10]  redis をインストール               |（検証中）
| [11]  GIT をアップデート                 |（検証中）
| [80]  python をインストール              |（検証中）
| [81]  tensorflow をインストール          |（検証中）
| [ e]  シェルを終了                       |
+------------------------------------------+
EOF
# | [11]  mysql 5.11 -> 5.7 + utf8mb4 (NG)   |（検証中）

    #入力された項目を読み込み、変数KEYに代入する
    read -p "項目を選択してください >> " MENU_NUMBER
    case "${MENU_NUMBER}" in  #変数MENU_NUMBERに合った内容でコマンドが実行される
      "1") FNC_ACTION ;;
      "2") FNC_ACTION ;;
      "3") FNC_ACTION ;;
      "4") FNC_ACTION ;;
      "5") FNC_ACTION ;;
      "6") FNC_ACTION ;;
      "7") FNC_ACTION ;;
      "8") FNC_ACTION ;;
      "9") FNC_ACTION ;;
      "10") FNC_ACTION ;;
      "11") FNC_ACTION ;;
      "80") FNC_ACTION ;;
      "81") FNC_ACTION ;;
      "e") break ;;
      *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
    read -p "ENTERを押してください。" BLANK
  done
}

########################################################
# FNC_ACTION 共通メソッド
FNC_ACTION(){
  FNC_${MENU_NUMBER}
  if [ $? != 0 ]; then
     echoRed "(${LINENO})  >> FNC_${MENU_NUMBER}で異常が発生しました"
  fi
}

########################################################
FNC_1(){
  echoGreen "(${LINENO}) >> [ 1]  開発用としてiptableとselinuxを解除"
  /etc/rc.d/init.d/iptables stop
  chkconfig iptables off
  chkconfig --list iptables
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
  chkconfig kdump off
  echoGreen "開発用パッケージをインストールします"
  sudo yum  -y update
  sudo yum -y groupinstall "Base" "Development tools"
  sudo yum install -y crontabs cronie-noanacron cronie-anacron

  cp -rf /usr/share/zoneinfo/Japan /etc/localtime
  sudo yum -y install ntp
  sudo ntpdate ntp.nict.jp

  SWAP_SETTING

  rm -rf /etc/localtime
  cp /usr/share/zoneinfo/Japan /etc/localtime

  return 0
}
#######################################################
FNC_2(){
  echoGreen "(${LINENO}) >> [ 2]  ruby をインストール"
  RUBY_INSTALL_SELECT
  return 0
}

########################################################
#  [3]
FNC_3(){
  echoGreen "(${LINENO}) >> [ 3]  rails をインストール"
  RUN_CHECK
  RAILS_VERSION_CHECK
  return 0
}

########################################################
FNC_4(){
  echoGreen "(${LINENO}) >> [ 4]  node.js をインストール"
  RUN_CHECK
  DEVELOP_PACKAGE_INSTALL
  NODE_INSTALL_CHECK
  yum -y install npm --enablerepo=epel
  npm install -g yarn

  echoGreen 'node.js のバージョンは以下となります'
  node -v
  echoGreen 'npm のバージョンは以下となります'
  npm -v
  echoGreen 'yarn のバージョンは以下となります'
  yarn -v
  return 0
}

########################################################
FNC_5(){
  echo "(${LINENO}) >> [ 5]  MYSQL 5.7 をインストール"

  echoGreen "現在のMYSQLのバージョンは、以下の通りです"
  if type mysqld >/dev/null 2>&1; then
    mysqld --version
  else
    echoRed "MYSQLはインストールされていませんでした"
  fi
  echo ""

  RUN_CHECK
  MYSQL_57_INSTALL
  return 0
}

########################################################
#  [6]
FNC_6(){
  echo "(${LINENO}) >> [ 6]  スワップ領域の割り当て"
  RUN_CHECK
  SWAP_SETTING
  return 0
}

########################################################
#  [7]
FNC_7(){
  echoGreen "(${LINENO}) >> [ 7]  ffmpeg（のみ） をインストール"
  RUN_CHECK
  FFMPEG_INSTALL
  # DEVELOP_PACKAGE_INSTALL
  # NODE_INSTALL_CHECK
  return 0
}

########################################################
#  [8]
FNC_8(){
  echoGreen "(${LINENO}) >> [ 8]  ImageMagick をインストール"
  RUN_CHECK
  yum -y install ImageMagick
  yum -y install ImageMagick-devel
  return 0
}

########################################################
#  [9]
FNC_9(){
  echoGreen "(${LINENO}) >> [ 9]  mecab をインストール"
  RUN_CHECK
  # yum -y install gcc-c++
  sudo yum update -y
  sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
  sudo yum makecache
  # sudo yum -y install mecab mecab-ipadic mecab-devel
  # sudo yum -y install libmecab1 libmecab-dev mecab mecab-ipadic mecab-ipadic-utf8 mecab-utils mecab-devel
  sudo yum install -y mecab mecab-devel mecab-ipadic git make curl xz
  echoGreen 'mecab のバージョンは以下となります'
  mecab --version
  echoYellow 'mecab の動作検証'
  echo 'すもももももももものうち' | mecab
  MECAB_IPADIC_INSTALL
  return 0
}

########################################################
#  [10]
FNC_10(){
  echoGreen "(${LINENO}) >> [10]  redis をインストール"
  RUN_CHECK
  REDIS_INSTALL
  return 0
}

########################################################
#  [11]
FNC_11(){
  echoGreen "(${LINENO}) >> [11]  GIT をアップデート"
  RUN_CHECK
  GIT_INSTALL
  return 0
}

########################################################
#  [80]
FNC_80(){
  echoGreen "(${LINENO}) >> [80]  python をインストール"
  RUN_CHECK
  PYTHON_INSTALL_CHECK
  return 0
}

########################################################
#  [81]
FNC_81(){
  echoGreen "(${LINENO}) >> [81]  tensorflow をインストール"
  RUN_CHECK
  # PYTHON_INSTALL_CHECK
  TENSORFLOW_INSTALL
  return 0
}

# ########################################################
# #  [12]
# FNC_12(){
#   echo "(${LINENO}) >> [12]  mysql 5.11 -> 5.7 + utf8mb4"
#   RUN_CHECK
#   MYSQL_51_2_57_VERSION_UP
#   return 0
# }


########################################################
#  各種の呼び出し処理
# 確認処理
RUN_CHECK(){
  while true; do
    cat << EOF
+--------------------------------+
| 実行しますが、よろしいですか？ |
+--------------------------------+
| > [1] 実行                     |
| > [2] 戻る                     |
+--------------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1")
        break ;;
      "2")
        FNC_MENU
        break ;;
      *)
        echo "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

# 必要パッケージのインストール処理
DEVELOP_PACKAGE_INSTALL(){
  echoGreen 'パッケージを最新にします。パスワードを聞かれることがあります。'
  sudo -v
  sudo yum update -y
  sudo yum install -y zlib
  sudo yum install -y zlib-devel
  sudo yum install -y openssl-devel
  sudo yum install -y sqlite-devel
  sudo yum install -y gcc-c++
  sudo yum install -y glibc-headers
  sudo yum install -y libyaml-devel
  sudo yum install -y readline
  sudo yum install -y readline-devel
  sudo yum install -y libffi-devel
  sudo yum install -y libxml2
  sudo yum install -y libxml2-devel
  sudo yum install -y libxslt
  sudo yum install -y libxslt-devel
  sudo yum install -y libyaml-devel
  sudo yum install -y make
  sudo yum -y install yum-cron
}

GIT_INSTALL(){
  if type git >/dev/null 2>&1; then
    # echo 'git install OK'
    echoGreen '現在、以下のGITのバージョンがインストールされています'
    git --version

    read -p "バージョンを変更しますか？（yes or no） >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "y" | "yes")
        sudo yum -y remove git
        GIT_VERSION_INSTALL ;;
        # break ;;
      "n" | "no")
        echoYellow "インストールを行わず、次のステップに移ります" ;;
        # break ;;
      *)
        echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  else
    echoGreen 'gitがインストールされていませんでした'
    GIT_VERSION_INSTALL
  fi
}

GIT_VERSION_INSTALL(){
  while true; do
    cat << EOF
+----------------------------------------+
| GITをインストールします                |
| どのバージョンをインストールしますか？ |
+----------------------------------------+
| > [1] 2系 (最新バージョン)             |
| > [2] 1.7 (centOS6系 デフォルト)       |
+----------------------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1")
        # yum install -y git
        # sudo yum -y remove git
        curl -s https://setup.ius.io/ | bash
        yum install -y git2u
        git clone git://git.kernel.org/pub/scm/git/git.git

        echoGreen 'git のバージョンは以下となります'
        git --version
        break ;;
      "2")
        yum install -y git
        echoGreen 'git のバージョンは以下となります'
        git --version
        break ;;
      *)   echo "(${LINENO})  >> キーが違います。" ;;
    esac
  done

}


RUBY_INSTALL_SELECT(){
  while true; do
    cat << EOF
+----------------------------+
| どのアプリを利用しますか？ |
+----------------------------+
| > [1] rvm                  |
| > [2] rbenv (会社推奨)     |
+----------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1")
        echoGreen "(${LINENO}) >> [2]  rvm で rubyをインストール"
        RUN_CHECK
        DEVELOP_PACKAGE_INSTALL
        RVM_INSTALL
        RVM_RUBY_VERSION_CHECK
        RVM_RUBY_INSTALL
        break ;;
      "2")
        echoGreen "(${LINENO}) >> [3]  rbenv で rubyをインストール"
        RUN_CHECK
        DEVELOP_PACKAGE_INSTALL
        RBENV_INSTALL
        RBENV_RUBY_VERSION_CHECK
        RBENV_RUBY_INSTALL
        break ;;
      *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

# rvmのインストール
RVM_INSTALL(){
  curl -L https://get.rvm.io | bash

  # 設定を反映
  source /etc/profile.d/rvm.sh
  # sh /etc/profile.d/rvm.sh
  # . /etc/profile.d/rvm.sh

  # 必要パッケージ一式揃える
  rvm requirements

  echo 'rvm のバージョンは以下となります'
  rvm -v
}

RVM_RUBY_VERSION_CHECK(){
  while true; do
    cat << EOF
+-----------------------------------+
| Ruby のバージョンを確認しますか？ |
+-----------------------------------+
| > [1] する                        |
| > [2] しない                      |
+-----------------------------------+
EOF

  read -p "項目を選択してください >> " KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
    "1") rvm list known ;;
    "2") break ;;
    *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

RVM_RUBY_INSTALL(){
  echo -n "バージョン : "
  read ans
  rvm install $ans
  rvm use $ans --default

  echoGreen 'ruby のバージョンは以下となります'
  ruby -v
}

# rbenvのインストール
RBENV_INSTALL(){
  # GIT_INSTALL
  yum install -y git

  git clone git://github.com/sstephenson/rbenv.git /usr/local/src/rbenv
  echo 'export RBENV_ROOT="/usr/local/src/rbenv"' >> /etc/profile.d/rbenv.sh
  echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
  source /etc/profile.d/rbenv.sh
  git clone git://github.com/sstephenson/ruby-build.git /usr/local/src/rbenv/plugins/ruby-build
  ls /usr/local/src/rbenv/plugins/ruby-build/bin/

  echoGreen 'rbenv のバージョンは以下となります'
  rbenv -v
}

RBENV_RUBY_VERSION_CHECK(){
  while true; do
    cat << EOF
+-----------------------------------+
| Ruby のバージョンを確認しますか？ |
+-----------------------------------+
| > [1] する                        |
| > [2] しない                      |
+-----------------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1") rbenv install --list ;;
      "2") break ;;
      *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

RBENV_RUBY_INSTALL(){
  echo -n "バージョン : "
  read ans
  rbenv install -v $ans
  rbenv rehash
  rbenv global $ans

  echoGreen 'ruby のバージョンは以下となります'
  ruby -v
}

RAILS_VERSION_CHECK(){
  while true; do
    cat << EOF
+------------------------------------------+
| Rails のバージョンはどれを利用しますか？ |
+------------------------------------------+
| > [1] 3.2.22.5                           |
| > [2] 4.0.13                             |
| > [3] 4.1.16                             |
| > [4] 4.2.10                             |
| > [5] 5.1.4                              |
| > [6] 最新                               |
| > [7] バージョン検索                     |
| > [8] 手動入力                           |
+------------------------------------------+
EOF

    read -p "項目を選択してください >> " RIALS_MENU_KEY
    case "${RIALS_MENU_KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1")
        RAILS_INSTALL 3.2.22.5
        break ;;
      "2")
        RAILS_INSTALL 4.0.13
        break ;;
      "3")
        RAILS_INSTALL 4.1.16
        break ;;
      "4")
        RAILS_INSTALL 4.2.10
        break ;;
      "5")
        RAILS_INSTALL 5.1.4
        break ;;
      "6")
        gem install rails --pre
        # break
        echoGreen 'rails のバージョンは以下となります'
        rails -v
        break ;;
      "7")
        gem query -ra -n  "^rails$"
        break ;;
      "8")
        read -p "バージョン : " RIALS_VERSION_NUM
        RAILS_INSTALL ${RIALS_VERSION_NUM}
        # break ;;
        ;;
      *)
        echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

RAILS_INSTALL(){
  gem install rack
  gem install rails -v  $1

  echoGreen 'rails のバージョンは以下となります'
  rails -v
}

NODE_INSTALL_CHECK(){
  while true; do
    cat << EOF
+----------------------------------------+
| nodejsを何経由でインストールしますか？ |
+----------------------------------------+
| > [1] yum (推奨)                       |
| > [2] nvm                              |
| > [3] nodebrew                         |
+----------------------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1")
        NODE_YUM_VERSION_INSTALL_CHECK
        break ;;
      "2")
        NVM_INSTALL
        NVM_RUBY_VERSION_CHECK
        NVM_RUBY_INSTALL
        break ;;
      "3")
        NODEBLEW_INSTALL
        NODEBLEW_RUBY_VERSION_CHECK
        NODEBLEW_RUBY_INSTALL
        break ;;
      *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}


NODE_YUM_VERSION_INSTALL_CHECK(){
  while true; do
    cat << EOF
+-----------------------------------------------------+
|       どのバージョンをインストールしますか？        |
+-----------------------------------------------------+
| > [1] CentOSのデフォルトのnode.jsをインストールする |
| > [2] node 5.Xをインストール                        |
| > [3] node 6.Xをインストール                        |
| > [4] node 7.Xをインストール                        |
| > [5] node 8.Xをインストール                        |
| > [6] node 9.Xをインストール                        |
+-----------------------------------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1")
        sudo yum install -y epel-release
        sudo yum install -y nodejs npm --enablerepo=epel
        node -v
        break ;;
      "2")
        curl -sL https://rpm.nodesource.com/setup_5.x | bash -
        yum install -y nodejs gcc-c++ make
        break ;;
      "3")
        curl -sL https://rpm.nodesource.com/setup_6.x | bash -
        yum install -y nodejs gcc-c++ make
        break ;;
      "4")
        curl -sL https://rpm.nodesource.com/setup_7.x | bash -
        yum install -y nodejs gcc-c++ make
        break ;;
      "5")
        curl -sL https://rpm.nodesource.com/setup_8.x | bash -
        yum install -y nodejs gcc-c++ make
        break ;;
      "6")
        curl -sL https://rpm.nodesource.com/setup_9.x | bash -
        yum install -y gcc-c++ make
        yum install -y nodejs
        break ;;
      *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

NVM_INSTALL(){
  # GIT_INSTALL
  yum install -y git

  git clone git://github.com/creationix/nvm.git ~/.nvm
  source ~/.nvm/nvm.sh
  nvm version
}

NVM_RUBY_VERSION_CHECK(){
  while true; do
    cat << EOF
+----------------------------------+
| node のバージョンを確認しますか？|
+----------------------------------+
| > [1] する                       |
| > [2] しない                     |
+----------------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1") nvm ls-remote ;;
      "2") break ;;
      *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

NVM_RUBY_INSTALL(){
  echo -n "バージョン(vは削除して記入) : "
  read ans
  nvm install $ans
  nvm alias default v$ans
  # yum install -y npm

  echoGreen 'node のバージョンは以下となります'
  node -v
}

NODEBLEW_INSTALL(){
  curl -L git.io/nodebrew | perl - setup
  export PATH=$HOME/.nodebrew/current/bin:$PATH
  source ~/.bashrc
  nodebrew help
}

NODEBLEW_RUBY_VERSION_CHECK(){
  while true; do
    cat << EOF
+----------------------------------+
| node のバージョンを確認しますか？|
+----------------------------------+
| > [1] する                       |
| > [2] しない                     |
+----------------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1") nodebrew ls-remote ;;
      "2") break ;;
      *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

NODEBLEW_RUBY_INSTALL(){
  echo -n "バージョン(vは削除して記入) : "
  read ans
  nodebrew install-binary v$ans
  nodebrew use v$ans
  # yum install -y npm

  echoGreen 'node のバージョンは以下となります'
  node -v
}

FFMPEG_INSTALL(){
  # FFmpeg
  echo 'FFmpeg  インストール'
  sudo yum install epel-release -y
  sudo yum update -y
  sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el6/x86_64/nux-dextop-release-0-2.el6.nux.noarch.rpm
  sudo yum install ffmpeg ffmpeg-devel -y
  echoGreen 'FFmpeg  インストール  完了'

  echo 'ffmpeg のバージョンは以下となります'
  ffmpeg -version

  # update
}


MECAB_IPADIC_INSTALL(){
  while true; do
    cat << EOF
+------------------------------------------+
|  ipadic-neologdをインストールしますか？  |
+------------------------------------------+
| > [y] yes                                |
| > [e] 終了する                           |
+------------------------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "y")
        echoYellow '決められた設定に沿ってインストールを行いますが、centOSの設定によっては失敗します'
        #path 登録
        echo 'export MECAB_PATH=/usr/lib64/libmecab.so.2' >> ~/.bash_profile
        source ~/.bash_profile
        sudo ./configure --with-charset=utf8

        # 必要パッケージのインストール
        sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
        sudo yum install -y mecab mecab-devel mecab-ipadic git make curl xz
        # sudo yum install -y mecab mecab-devel mecab-ipadic make curl xz
        # GIT_INSTALL

        git clone git://git.kernel.org/pub/scm/git/git.git

        # 辞書の取得
        WORKING=/tmp/mecabdic
        mkdir -p $WORKING
        cd $WORKING
        git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git

        # インストール
        cd mecab-ipadic-neologd
        ./bin/install-mecab-ipadic-neologd -n

        echoGreen 'mecab のバージョンは以下となります'
        mecab --version

        echoGreen 'mecab の動作テスト'
        echo 'すもももももももものうち' | mecab -d /usr/lib64/mecab/dic/mecab-ipadic-neologd

        echoYellow '---------------------------------------------------------------------------------'
        echoYellow 'もし、可動しなかった場合、下記で表示されたパスを以下のコマンドで登録し、再インストールしてください'
        sudo find / -name libmecab.so*
        echoYellow ''
        echoYellow 'コマンド①：echo "export MECAB_PATH=/usr/lib64/libmecab.so.2" >> ~/.bash_profile'
        echoYellow '                                    ------------------------'
        echoYellow '                                    ここを書き換えてください'
        echoYellow 'コマンド②：source ~/.bash_profile'
        echoYellow '---------------------------------------------------------------------------------'
        echoYellow ''
        echoYellow 'mecab-ipadic-neologd のインストール先は、以下の通りです'
        echo `mecab-config --dicdir`"/mecab-ipadic-neologd"

        break ;;
      "e")  break ;;
      *) echo "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

REDIS_INSTALL(){
  sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
  sudo yum -y --enablerepo=remi install redis

  echoGreen 'redis のバージョンは以下となります'
  redis-server --version
}


MYSQL_51_2_57_VERSION_UP(){
  cat /etc/centos-release
  mysql --version

  service mysqld stop
  yum remove -y mysql*
  yum -y install http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
  yum-config-manager --disable mysql55-community
  yum-config-manager --enable mysql56-community
  yum install -y mysql mysql-devel mysql-server mysql-utilities
  service mysqld start
  mysql_upgrade -u root
  mysql --version

  service mysqld stop
  yum remove -y mysql*
  yum -y install http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
  yum-config-manager --disable mysql56-community
  yum-config-manager --enable mysql57-community-dmr
  yum install -y mysql mysql-devel mysql-server mysql-utilities

  echo 'character-set-server=utf8mb4' >> /etc/my.cnf
  echo '' >> /etc/my.cnf
  echo '[client]' >> /etc/my.cnf
  echo 'default-character-set=utf8mb4' >> /etc/my.cnf

  service mysqld start
  mysql_upgrade -u root
  service mysqld restart
  mysql --version

  echo "今から投入済みのデータの文字コードを変更します"
  mysql -e "show databases" >> database_list.text

  cat database_list.text | while read line
  do
    if [ "$line" = "Database" -o "$line" = "information_schema" -o "$line" = "mysql" -o "$line" = "performance_schema" -o "$line" = "sys" -o "$line" = "test" ]; then
      echo "$line font change no"
    else
      echo "$line font change utf8 => utf8mb4"
      mysql -e "alter database $line character set utf8mb4;"
      (mysql "$line" -e "show tables" --batch --skip-column-names | xargs -I{} echo 'alter table `'{}'` convert to character set utf8mb4;') > alters.sql
    fi
  done

  cat alters.sql | while read line
  do
    echo "$line"
  done

  rm -rf database_list.text
  rm -rf alters.sql

  echo 'MySQL のバージョンは以下となります'
  mysql --version
}


MYSQL_57_INSTALL(){
  # 古いバージョンを削除
  yum -y remove mysql*

  # インストール
  yum -y install https://dev.mysql.com/get/mysql57-community-release-el6-11.noarch.rpm
  yum -y install mysql-community-server
  yum -y install mysql-devel

  # バージョン確認
  mysqld --version

  # 設定
  # read -p "Press [Enter] key to resume."
  echo ""
  read -p "MYSQLの設定で、rootのパスワードを「なし」にしますか？（yes or no） >> " KEY
  case "${KEY}" in
    "y" | "yes"| "Y")
      MYSQL_ROOT_PASS_SEKYURY=1 ;;
    "n" | "no"| "N")
      MYSQL_ROOT_PASS_SEKYURY=0 ;;
    *)
      echoRed "(${LINENO})  >> キーが違います。"
  esac

  read -p "MYSQLの設定で、文字コードをutf8mb4にしても宜しいですか？（yes or no） >> " KEY
  case "${KEY}" in
    "y" | "yes")
      MYSQL_UTF8_ENCODE=1 ;;
    "n" | "no")
      MYSQL_UTF8_ENCODE=0 ;;
    *)
      echoRed "(${LINENO})  >> キーが違います。"
  esac

  # 実行
  if [ ${MYSQL_ROOT_PASS_SEKYURY} = 1 ]; then
    echo '' >> /etc/my.cnf
    echo 'skip-grant-tables' >> /etc/my.cnf
  fi

  if [ ${MYSQL_UTF8_ENCODE} = 1 ]; then
    echo 'character-set-server=utf8mb4' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '[client]' >> /etc/my.cnf
    echo 'default-character-set=utf8mb4' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
  else
    echo 'character-set-server=utf8' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '[client]' >> /etc/my.cnf
    echo 'default-character-set=utf8' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
    echo '' >> /etc/my.cnf
  fi

  # 起動
  service mysqld restart

  DB_PASSWORD=$(grep "A temporary password is generated" /var/log/mysqld.log | sed -s 's/.*root@localhost: //')
  echoRed "初期パスワードは、「${DB_PASSWORD}」です。"
  echoRed "このパスワードは、場合によっては必要となりますので、"
  echoRed "メモしておくことをお勧めします"
  echo ""

  if [ ${MYSQL_ROOT_PASS_SEKYURY} = 0 ]; then
    read -p "MYSQLの設定で、rootのパスワード設定を行いますか？（yes or no） >> " KEY
    case "${KEY}" in
      "y" | "yes")
        mysql_secure_installation
        break ;;
      "n" | "no")
        break ;;
      *)
        echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  else
    echoRed "パスワードがOFFとなっています"
    echoRed "※本番時の利用では注意してください"
  fi

  chkconfig mysqld on
  # break;;
}


PYTHON_INSTALL_CHECK(){
  if type python >/dev/null 2>&1; then
    # echo 'git install OK'
    echoGreen '現在、以下のpythonのバージョンがインストールされています'
    python --version

    read -p "バージョンを変更しますか？（yes or no） >> " KEY
    case "${KEY}" in
      "y" | "yes")
        PYTHON_INSTALL_PATTERN ;;
      "n" | "no")
        echoYellow "インストールを行わず、次のステップに移ります" ;;
      *)
        echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  else
    echoGreen 'gitがインストールされていませんでした'
    PYTHON_INSTALL_PATTERN
  fi
}

PYTHON_INSTALL_PATTERN(){
  while true; do
    cat << EOF
+----------------------------------------+
| pythonを何経由でインストールしますか？ |
+----------------------------------------+
| > [1] yum (作成中)                     |
| > [2] pyenv (推奨)                     |
+----------------------------------------+
EOF
# | > [3] nodebrew                         |

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1")
        # NODE_YUM_VERSION_INSTALL_CHECK
        break ;;
      "2")
        PYENV_INSTALL
        PYENV_PYTHON_VERSION_CHECK
        PYENV_PYTHON_INSTALL
        break ;;
      # "3")
      #   NODEBLEW_INSTALL
      #   NODEBLEW_RUBY_VERSION_CHECK
      #   NODEBLEW_RUBY_INSTALL
      #   break ;;
      *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

PYENV_INSTALL(){
  yum install -y gcc
  yum install -y gcc-c++
  yum install -y make
  yum install -y openssl-devel
  yum install -y bzip2-devel
  yum install -y zlib-devel
  yum install -y readline-devel
  yum install -y sqlite-devel
  yum install -y bzip2
  yum install -y sqlite
  yum install -y zlib-devel
  yum install -y bzip2
  yum install -y bzip2-devel
  yum install -y readline-devel
  yum install -y sqlite
  yum install -y sqlite-devel
  yum install -y openssl-devel

  git clone https://github.com/yyuu/pyenv.git ~/.pyenv

  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
  echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
  source ~/.bash_profile

  echoGreen 'pyenv のバージョンは以下となります'
  pyenv --version
}

PYENV_PYTHON_VERSION_CHECK(){
  while true; do
    cat << EOF
+------------------------------------+
| python のバージョンを確認しますか？|
+------------------------------------+
| > [1] する                         |
| > [2] しない                       |
+------------------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1") pyenv install --list ;;
      "2") break ;;
      *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

PYENV_PYTHON_INSTALL(){
  read -p "バージョン :" install_version
  pyenv install ${install_version}
  pyenv global  ${install_version}
  pyenv rehash

  echoGreen 'python のバージョンは以下となります'
  python --version

  echoGreen 'pip のバージョンは以下となります'
  pip -V
}


TENSORFLOW_INSTALL(){
  PYENV_INSTALL
  pyenv install 3.6.4
  pyenv global  3.6.4
  pyenv rehash

  while true; do
    cat << EOF
+--------------------------------------------------------+
| tensorflow のどちらのバージョンをインストールしますか？|
+--------------------------------------------------------+
| > [1] CPU版                                            |
| > [2] GPU版                                            |
+--------------------------------------------------------+
EOF

    read -p "項目を選択してください >> " KEY
    case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
      "1")
        pip install tensorflow
        break;;
      "2")
        pip install tensorflow-gpu
        break;;
      *) echoRed "(${LINENO})  >> キーが違います。" ;;
    esac
  done
}

SWAP_SETTING(){
  echoGreen "(${LINENO})  >> スワップ領域を自動で割り当てます"
  echoGreen "現在のスワップ領域は以下の通りです"
  free

  SWAPFILENAME=/swap.img
  MEMSIZE=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`

  if [ $MEMSIZE -lt 2097152 ]; then
    SIZE=$((MEMSIZE * 2))k
  elif [ $MEMSIZE -lt 8388608 ]; then
    SIZE=${MEMSIZE}k
  elif [ $MEMSIZE -lt 67108864 ]; then
    SIZE=$((MEMSIZE / 2))k
  else
    SIZE=4194304k
  fi

  fallocate -l $SIZE $SWAPFILENAME && mkswap $SWAPFILENAME && swapon $SWAPFILENAME

  echoGreen "スワップ領域を以下に設定しました"
  free
}


########################################################
#  エンド処理
FNC_MENU      #関数FNC_MENUを呼ぶ
