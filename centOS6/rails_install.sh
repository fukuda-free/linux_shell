#!/bin/sh
########################################################
# rails 用シェル
########################################################

########################################################
# メソッド群（TODO：基本弄らない）
########################################################
# rails instlal
RAILS_INSTALL(){
  gem install rack
  gem install rails -v  $1
}
########################################################

case "${1}" in
  "4.2" )
    rails_version='4.2.11.1';;
  "5.1" )
    rails_version='5.1.7';;
  "5.2" )
    rails_version='5.2.3';;
  * )
    rails_version='5.2.3';;
esac

echo "rails ${rails_version} install"
RAILS_INSTALL ${rails_version}

echo 'rails のバージョンは以下となります'
rails -v
echo ''
