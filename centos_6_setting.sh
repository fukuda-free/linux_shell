#!/bin/sh
########################################################
# Ruby On Rails 環境構築用シェル
# 作成者  fukuda
# 作成日  2016/01/06
########################################################

########################################################
#  メニュー項目画面
FNC_MENU(){
  while true; do
    cat << EOF
+-----------------------------------------+
|                【 MENU 】         v 4.5 |
+-----------------------------------------+
| [1]  開発用としてiptableとselinuxを解除 |
| [2]  ruby をインストール                |
| [3]  rails をインストール               |（検証中）
| [4]  node.js をインストール             |（検証中）
| [5]  ffmpeg（のみ） をインストール      |（検証中）
| [6]  ImageMagick をインストール         |（検証中）
| [7]  mecab をインストール               |（検証中）
| [e]  シェルを終了                       |
+-----------------------------------------+
EOF
# | [6]  redis をインストール               |（検証中）
# | [7]  mysql 5.11 -> 5.7 + utf8mb4 (NG)   |（検証中）
# | [8]  5.7 をインストール                 |（検証中）

  #入力された項目を読み込み、変数KEYに代入する
  read -p "項目を選択してください >>" KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
    "1") FNC_ACTION ;;
    "2") FNC_ACTION ;;
    "3") FNC_ACTION ;;
    "4") FNC_ACTION ;;
    "5") FNC_ACTION ;;
    "6") FNC_ACTION ;;
    "7") FNC_ACTION ;;
    # "8") FNC_ACTION ;;
    "e") break ;;
    *) echo "($LINENO)  >> キーが違います。" ;;
    esac
    read -p "ENTERを押してください。" BLANK
  done
}

########################################################
# FNC_ACTION 共通メソッド
FNC_ACTION(){
  FNC_${KEY}
  if [ $? != 0 ]; then
     echo "($LINENO)  >> FNC_${KEY}で異常が発生しました"
  fi
}

########################################################
#  [1]
FNC_1(){
  echo "($LINENO) >> [1]  開発用としてiptableとselinuxを解除"
  /etc/rc.d/init.d/iptables stop
  chkconfig iptables off
  chkconfig --list iptables
  setenforce 0
  # sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
  chkconfig kdump off
  echo "開発用パッケージをインストールします"
  sudo yum -y groupinstall "Base" "Development tools"
  return 0
}

########################################################
#  [2]
FNC_2(){
  echo "($LINENO) >> [2]  ruby をインストール"
  RUBY_INSTALL_SELECT
  return 0
}

########################################################
#  [3]
FNC_3(){
  echo "($LINENO) >> [3]  rails をインストール"
  RUN_CHECK
  RAILS_VERSION_CHECK
  return 0
}

########################################################
#  [4]
FNC_4(){
  echo "($LINENO) >> [4]  node.js をインストール"
  RUN_CHECK
  DEVELOP_PACKAGE_INSTALL
  NODE_INSTALL_CHECK
  yum -y install npm --enablerepo=epel
  echo 'npm のバージョンは以下となります'
  npm -v
  npm install -g yarn
  echo 'yarn のバージョンは以下となります'
  yarn -v
  return 0
}

########################################################
#  [5]
FNC_5(){
  echo "($LINENO) >> [5]  ffmpeg をインストール"
  RUN_CHECK
  FFMPEG_INSTALL
  # DEVELOP_PACKAGE_INSTALL
  # NODE_INSTALL_CHECK
  return 0
}

########################################################
#  [6]
FNC_6(){
  echo "($LINENO) >> [6]  ImageMagick をインストール"
  RUN_CHECK
  yum -y install ImageMagick
  yum -y install ImageMagick-devel
  return 0
}

########################################################
#  [7]
FNC_7(){
  echo "($LINENO) >> [7]  mecab をインストール"
  RUN_CHECK
  sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
  sudo yum install -y mecab mecab-devel
  sudo yum install -y mecab-ipadic
  echo 'mecab のバージョンは以下となります'
  mecab --version
  echo 'mecab の動作検証'
  echo 'すもももももももものうち' | mecab
  MECAB_IPADIC_INSTALL
  return 0
}

# ########################################################
# #  [6]
# FNC_6(){
#   echo "($LINENO) >> [6]  redis をインストール"
#   RUN_CHECK
#   REDIS_INSTALL
#   return 0
# }


# ########################################################
# #  [7]
# FNC_7(){
#   echo "($LINENO) >> [7]  mysql 5.11 -> 5.7 + utf8mb4"
#   RUN_CHECK
#   MYSQL_51_2_57_VERSION_UP
#   return 0
# }


# ########################################################
# #  [7]
# FNC_8(){
#   echo "($LINENO) >> [8]  5.7 をインストール"
#   RUN_CHECK
#   MYSQL_57_INSTALL
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

  read -p "項目を選択してください >>" KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
    "1") break ;;
    "2") FNC_MENU ;;
    *) echo "($LINENO)  >> キーが違います。" ;;
    esac
  done
}

# 必要パッケージのインストール処理
DEVELOP_PACKAGE_INSTALL(){
  echo 'パッケージを最新にします。パスワードを聞かれることがあります。'
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

RUBY_INSTALL_SELECT(){
  while true; do
    cat << EOF
+----------------------------+
| どのアプリを利用しますか？ |
+----------------------------+
| > [1] rvm                  |
| > [2] rbenv                |
+----------------------------+
EOF

  read -p "項目を選択してください >>" KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
    "1")
      echo "($LINENO) >> [2]  rvm で rubyをインストール"
      RUN_CHECK
      DEVELOP_PACKAGE_INSTALL
      RVM_INSTALL
      RVM_RUBY_VERSION_CHECK
      RVM_RUBY_INSTALL
      break ;;
    "2")
      echo "($LINENO) >> [3]  rbenv で rubyをインストール"
      RUN_CHECK
      DEVELOP_PACKAGE_INSTALL
      RBENV_INSTALL
      RBENV_RUBY_VERSION_CHECK
      RBENV_RUBY_INSTALL
      break ;;
    *) echo "($LINENO)  >> キーが違います。" ;;
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

  read -p "項目を選択してください >>" KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
    "1") rvm list known ;;
    "2") break ;;
    *) echo "($LINENO)  >> キーが違います。" ;;
    esac
  done
}

RVM_RUBY_INSTALL(){
  echo -n "バージョン : "
  read ans
  rvm install $ans
  rvm use $ans --default

  echo 'ruby のバージョンは以下となります'
  ruby -v
}

# rbenvのインストール
RBENV_INSTALL(){
  sudo yum -y install git
  git clone git://github.com/sstephenson/rbenv.git /usr/local/src/rbenv
  echo 'export RBENV_ROOT="/usr/local/src/rbenv"' >> /etc/profile.d/rbenv.sh
  echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
  source /etc/profile.d/rbenv.sh
  git clone git://github.com/sstephenson/ruby-build.git /usr/local/src/rbenv/plugins/ruby-build
  ls /usr/local/src/rbenv/plugins/ruby-build/bin/

  echo 'rbenv のバージョンは以下となります'
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

  read -p "項目を選択してください >>" KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
    "1") rbenv install --list ;;
    "2") break ;;
    *) echo "($LINENO)  >> キーが違います。" ;;
    esac
  done
}

RBENV_RUBY_INSTALL(){
  echo -n "バージョン : "
  read ans
  rbenv install -v $ans
  rbenv rehash
  rbenv global $ans

  echo 'ruby のバージョンは以下となります'
  ruby -v
}

RAILS_VERSION_CHECK(){
  while true; do
    cat << EOF
|------------------------------------------|
| Rails のバージョンはどれを利用しますか？ |
|------------------------------------------|
| > [1] 3.2.22.5                           |
| > [2] 4.0.13                             |
| > [3] 4.1.16                             |
| > [4] 4.2.10                             |
| > [5] 5.1.4                              |
| > [6] 最新                               |
| > [7] バージョン検索                     |
| > [8] 手動入力                           |
|------------------------------------------|
EOF

  read -p "項目を選択してください >>" KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
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
      break ;;
    "7")
      gem query -ra -n  "^rails$" ;;
    "8")
      echo -n "バージョン : "
      read ans
      RAILS_INSTALL $ans
      break ;;
    *)
      echo "($LINENO)  >> キーが違います。" ;;
    esac
  done
}

RAILS_INSTALL(){
  gem install rack
  gem install rails -v  $1

  echo 'rails のバージョンは以下となります'
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

  read -p "項目を選択してください >>" KEY
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
    *) echo "($LINENO)  >> キーが違います。" ;;
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

  read -p "項目を選択してください >>" KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
    "1")
      sudo yum install -y epel-release
      sudo yum install -y nodejs npm --enablerepo=epel
      # yum install -y npm --enablerepo=epel
      node -v
      break ;;
    "2")
      curl -sL https://rpm.nodesource.com/setup_5.x | bash -
      yum install -y nodejs gcc-c++ make
      echo 'node.js のバージョンは以下となります'
      node -v
      break ;;
    "3")
      curl -sL https://rpm.nodesource.com/setup_6.x | bash -
      yum install -y nodejs gcc-c++ make
      echo 'node.js のバージョンは以下となります'
      node -v
      break ;;
    "4")
      curl -sL https://rpm.nodesource.com/setup_7.x | bash -
      yum install -y nodejs gcc-c++ make
      echo 'node.js のバージョンは以下となります'
      node -v
      break ;;
    "5")
      curl -sL https://rpm.nodesource.com/setup_8.x | bash -
      yum install -y nodejs gcc-c++ make
      echo 'node.js のバージョンは以下となります'
      node -v
      break ;;
    "6")
      curl -sL https://rpm.nodesource.com/setup_9.x | bash -
      yum install -y nodejs gcc-c++ make
      echo 'node.js のバージョンは以下となります'
      node -v
      break ;;
    *) echo "($LINENO)  >> キーが違います。" ;;
    esac
  done
}

NVM_INSTALL(){
  sudo yum -y install git
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

  read -p "項目を選択してください >>" KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
    "1") nvm ls-remote ;;
    "2") break ;;
    *) echo "($LINENO)  >> キーが違います。" ;;
    esac
  done
}

NVM_RUBY_INSTALL(){
  echo -n "バージョン(vは削除して記入) : "
  read ans
  nvm install $ans
  nvm alias default v$ans
  # yum install -y npm

  echo 'node のバージョンは以下となります'
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

  read -p "項目を選択してください >>" KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
    "1") nodebrew ls-remote ;;
    "2") break ;;
    *) echo "($LINENO)  >> キーが違います。" ;;
    esac
  done
}

NODEBLEW_RUBY_INSTALL(){
  echo -n "バージョン(vは削除して記入) : "
  read ans
  nodebrew install-binary v$ans
  nodebrew use v$ans
  # yum install -y npm

  echo 'node のバージョンは以下となります'
  node -v
}

FFMPEG_INSTALL(){
  # FFmpeg
  echo 'FFmpeg  インストール'
  sudo yum install epel-release -y
  sudo yum update -y
  sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el6/x86_64/nux-dextop-release-0-2.el6.nux.noarch.rpm
  sudo yum install ffmpeg ffmpeg-devel -y
  echo 'FFmpeg  インストール  完了'

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

  read -p "項目を選択してください >>" KEY
  case "${KEY}" in  #変数KEYに合った内容でコマンドが実行される
    "y")
      echo '決められた設定に沿ってインストールを行いますが、centOSの設定によっては失敗します'
      #path 登録
      echo 'export MECAB_PATH=/usr/lib64/libmecab.so.2' >> ~/.bash_profile
      source ~/.bash_profile

      # 必要パッケージのインストール
      sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
      sudo yum install -y mecab mecab-devel mecab-ipadic git make curl xz

      # 辞書の取得
      WORKING=/tmp/mecabdic
      mkdir -p $WORKING
      cd $WORKING
      git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git

      # インストール
      cd mecab-ipadic-neologd
      ./bin/install-mecab-ipadic-neologd -n

      echo 'mecab のバージョンは以下となります'
      mecab --version

      echo 'mecab の動作テスト'
      echo 'すもももももももものうち' | mecab -d /usr/lib64/mecab/dic/mecab-ipadic-neologd


      echo 'もし、可動しなかった場合、下記で表示されたパスを登録してください'
      sudo find / -name libmecab.so*
      echo 'echo "export MECAB_PATH=/usr/lib64/libmecab.so.2" >> ~/.bash_profile'
      echo '                        ------------------------'
      echo '                        ここを書き換えてください'
      echo 'source ~/.bash_profile'

      echo 'mecab-ipadic-neologd のインストール先は、以下の通りです'
      echo `mecab-config --dicdir`"/mecab-ipadic-neologd"

      break ;;
    "e")  break ;;
    *) echo "($LINENO)  >> キーが違います。" ;;
    esac
  done
}



REDIS_INSTALL(){
  wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
  sudo rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
  sudo yum --enablerepo=remi,epel install redis -y
  sudo service redis start
  sudo chkconfig redis on

  echo 'redis のバージョンは以下となります'
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
  # デジタル署名をインポートする
  sudo rpm --import http://dev.mysql.com/doc/refman/5.7/en/checking-gpg-signature.html

  # yumリポジトリの設定をインストールする
  sudo rpm -ihv http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm

  # yumリポジトリをlistする
  yum --disablerepo=\* --enablerepo='mysql57-community*' list available

  # MySQL Server 5.7をインストールする
  sudo yum --enablerepo='mysql57-community*' install -y mysql-community-server
  yum install mysql-devel

  echo 'MySQL のバージョンは以下となります'
  mysql --version
}

########################################################
#  エンド処理
FNC_MENU      #関数FNC_MENUを呼ぶ
