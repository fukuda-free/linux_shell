#!/bin/sh
########################################################
# ruby インストール
# 作成者  fukuda
# 更新日  2018/05/07
########################################################

########################################################
# rbenvのインストール
echo "rbenv install"
echo ""

# GIT_INSTALL(予備)
yum install -y git

git clone git://github.com/sstephenson/rbenv.git /usr/local/src/rbenv
echo 'export RBENV_ROOT="/usr/local/src/rbenv"' >> /etc/profile.d/rbenv.sh
echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
source /etc/profile.d/rbenv.sh
git clone git://github.com/sstephenson/ruby-build.git /usr/local/src/rbenv/plugins/ruby-build
ls /usr/local/src/rbenv/plugins/ruby-build/bin/

echo 'rbenv のバージョンは以下となります'
rbenv -v
echo ""

case "${1}" in
  "2.4" )
    ruby_version='2.4.6';;
  "2.5" )
    ruby_version='2.5.5';;
  "2.6" )
    ruby_version='2.6.3';;
  * )
    ruby_version='2.5.5';;
esac

echo "ruby ${ruby_version} install"
rbenv install -v ${ruby_version}
rbenv rehash
rbenv global ${ruby_version}
echo ""

echo 'ruby のバージョンは以下となります'
ruby -v
echo ""
