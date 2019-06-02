# 使い方
# rails plugin new my_engine --mountable
#                             -d mysql
#                             -m rails_engine_template.rb
#                             --skip-test-unit
#                             --dummy-path=spec/dummy


# add to Gemfile
append_file 'Gemfile', <<-CODE


group :development, :test do
  gem 'foreman'
  gem 'annotate'

  # コード整理
  gem 'rubocop', require: false
  gem 'erb_lint', require: false

  # guard
  gem 'guard'
  gem 'guard-shell'      , require: false
  gem 'guard-migrate'    , require: false
  gem 'guard-rspec'      , require: false
  gem 'guard-rubocop'    , require: false
  gem 'guard-livereload' , require: false

  # test
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

CODE


# Bundler
# Bundler.with_clean_env do
  # run 'bundle install --path vendor/bundle --jobs=4 --without production'
# end


# Checker
# ----------------------------------------------------------------
get 'https://gitlab.ai-q.biz/public-project/rails_template/raw/master/setting_file/.rubocop.yml', '.rubocop.yml'
get 'https://gitlab.ai-q.biz/public-project/rails_template/raw/master/setting_file/Guardfile', 'Guardfile'
get 'https://gitlab.ai-q.biz/public-project/rails_template/raw/master/setting_file/Procfile', 'Procfile'
# run "bundle exec rake db:create:all"

puts ''
puts '################################################################'
puts '#                                                              #'
puts '#  XXX.gemspec 内に記載されているTODO 部分を修正後、           #'
puts '#  以下のコマンドを実行してください                            #'
puts '#  「bundle install --path vendor/bundle --jobs=4」            #'
puts '#  「bundle exec rake db:create:all」                          #'
puts '#  「gem install foreman」                                     #'
puts '#                                                              #'
puts '################################################################'

###############################################################
#  Rspecの設定の場合方法
#
#  step.1
#    XXX.gemspec 内に記載されているTODO 部分を修正後、
#   「s.add_development_dependency 'rspec-rails'」を追加
#
#  step.2
#    lib/engine_name/engine.rb に  、以下を追加
#    ------------------
#      config.generators do |g|
#        g.test_framework :rspec
#      end
#    ------------------
#
#  step.3
#    「rails generate rspec:install」        を実行
#
#  step.4
#    .rspec に以下を追記
#    ------------------
#    # 出力結果を色分け
#    --color
#    # rails_helperの読み込み
#    --require rails_helper
#    # 出力結果をドキュメント風に見やすくする
#    --format documentation
#    ------------------
#
#  step.5
#    spec/rails_helper.rb の
#      「require File.expand_path('../../config/environment', __FILE__)」 を
#      「require File.expand_path('../dummy/config/environment.rb', __FILE__)」 に修正
#
###############################################################

# https://www.codementor.io/mohnishjadwani/how-to-setup-rspec-factory-bot-and-spring-for-a-rails-5-engine-qjdpthfb1
#
# bundle exec rake db:create:all
# rails db:migrate RAILS_ENV=test
# rails railties:install:migrations
# rails db:migrate