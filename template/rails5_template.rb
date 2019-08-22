# Create .gitignore
run "gibo OSX Linux Ruby Rails Vim > .gitignore" rescue nil
gsub_file ".gitignore", /^config\/initializers\/secret_token.rb\n/, ""
gsub_file ".gitignore", /^config\/secrets.yml\n/, ""


# Ruby Version ------------------------------------------------------
ruby_version = `ruby -v`.scan(/\d\.\d\.\d/).flatten.first
insert_into_file 'Gemfile',%(
ruby '#{ruby_version}'
), after: "source 'https://rubygems.org'"
run "echo '#{ruby_version}' > ./.ruby-version"


# rails app setting ------------------------------------------------------
APPLICATION_CSS  = 'app/assets/stylesheets/application.css'.freeze
APPLICATION_SCSS = 'app/assets/stylesheets/application.scss'.freeze

@app_name = app_name
@database = options['database']


# gem flag set ------------------------------------------------------
# @flag = Hash.new(false)
# @flag[:use_devise] = yes?('Use devise? [y|n]')
# if @flag[:use_devise]
#   @flag[:initialize_devise] = yes?("\tInitialize devise? [y|n]")
#   @flag[:use_omniauth]      = yes?("\tUse omniauth? [y|n]")
# end

# @flag[:use_haml] = yes?('Use haml? [y|n]')
# @flag[:use_bootstrap] = yes?('Use bootstrap? [y|n]')


# add to Gemfile ------------------------------------------------------
append_file 'Gemfile', <<-CODE

# ============================
# Environment Group
# ============================
group :development do
  gem 'erb2haml'

  # スキーマとルート情報に注釈を付けます
  gem 'annotate'

  # N + 1を殺すのに役立ちます
  gem 'bullet'

  # scaffoldまたは他の生成コマンドによってhamlビューを生成する
  gem 'haml-rails'

  # Syntax Checker
  # フックイベントの事前コミット、事前プッシュ
  gem 'overcommit', require: false

  # 静的分析セキュリティ脆弱性スキャナー
  gem 'brakeman', require: false

  # gemの脆弱なバージョンをチェックします
  gem 'bundler-audit', require: false

  # HAMLの構文チェッカー
  gem 'haml-lint', require: false

  # CSSの構文チェッカー
  gem 'ruby_css_lint', require: false

  # Rubyの静的コードアナライザー
  gem 'rubocop', require: false
end

group :development, :test do
  # Pry + 拡張
  gem 'pry-rails'
  gem 'pry-byebug'

  # PryコンソールにSQL結果を表示する
  gem 'hirb'
  gem 'awesome_print'

  # PG/MySQL Log Formatter
  gem 'rails-flog'

  # Rspec
  gem 'rspec-rails'

  # test fixture
  gem 'factory_bot_rails'

  # ファイル変更のイベントを処理する
  gem 'guard-rspec',      require: false
  gem 'guard-rubocop',    require: false
  gem 'guard-livereload', require: false
end

group :test do
  # HTTPリクエストのモック
  gem 'webmock'
  gem 'vcr'

  # Time Mock
  gem 'timecop'

  # テストデータの生成をサポート
  gem 'faker'

  # クリーニングテストデータ
  gem 'database_rewinder'

  # このgemは、コントローラーテストに割り当てを戻します
  gem 'rails-controller-testing'

  # カバレッジ
  gem 'simplecov', require: false
end

# ============================
# View
# ============================
# Bootstrap & Bootswatch & font-awesome
# gem 'bootstrap-sass'
# gem 'bootswatch-rails'
# gem 'font-awesome-rails'

# Fast Haml
gem 'faml'

# Pagenation
gem 'kaminari'

# ============================
# Utils
# ============================
# プロセス管理
gem 'foreman'

CODE


# bundle install ------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle install --path vendor/bundle --jobs=4'
  # run 'bundle install --path vendor/bundle --jobs=4 --without production'
end


# set config/application.rb ------------------------------------------------------
application  do
  %q{
    # Set timezone
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # Set locale
    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja
    I18n.available_locales = [:en, :ja]

    # Set generator
    config.generators do |g|
      g.orm :active_record
      g.template_engine :haml
      g.test_framework :rspec, :fixture => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
      g.view_specs false
      g.controller_specs true
      g.routing_specs false
      g.helper_specs false
      g.request_specs false
      g.assets false
      g.helper false
    end
  }
end


# For Bullet (N+1 Problem) ------------------------------------------------------
insert_into_file 'config/environments/development.rb', %(
  # Bullet Setting (help to kill N + 1 query)
  config.after_initialize do
    Bullet.enable = true        # Bulletプラグインを有効
    Bullet.alert = true         # JavaScriptでの通知
    Bullet.bullet_logger = true # log/bullet.logへの出力
    Bullet.console = true       # ブラウザのコンソールログに記録
    Bullet.rails_logger = true  # Railsログに出力
  end
), after: 'config.assets.debug = true'


# set Japanese locale ------------------------------------------------------
remove_file 'config/locales/en.yml'
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/en.yml -P config/locales/'
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -P config/locales/'
# get 'https://raw.githubusercontent.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml', 'config/locales/ja.yml'
# run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -P config/locales/'


# Puma(App Server) ------------------------------------------------------
run 'rm -rf config/puma.rb'
get 'https://raw.githubusercontent.com/fukuda-free/linux_shell/master/template/puma.rb', 'config/puma.rb'


# Procfile ------------------------------------------------------
run "echo 'web: bundle exec puma -C config/puma.rb' > Procfile"


# Annotate (Generating rake task) ------------------------------------------------------
run 'bundle exec rails g annotate:install'

# Rspec ------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle exec rails g rspec:install'
end

run "echo '--color -f d' > .rspec"

insert_into_file 'spec/rails_helper.rb',%(
# Coverage
require 'simplecov'
SimpleCov.start 'rails'
), after: "require 'rspec/rails'"

insert_into_file 'spec/rails_helper.rb',%(
  config.order = 'random'
  config.before :suite do
    DatabaseRewinder.clean_all
  end
  config.after :each do
    DatabaseRewinder.clean
  end
  config.before :all do
    FactoryGirl.reload
    FactoryGirl.factories.clear
    FactoryGirl.sequences.clear
    FactoryGirl.find_definitions
  end
  config.include FactoryGirl::Syntax::Methods
  VCR.configure do |c|
      c.cassette_library_dir = 'spec/vcr'
      c.hook_into :webmock
      c.allow_http_connections_when_no_cassette = true
  end
  [:controller, :view, :request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, type: type
    config.include ::Rails::Controller::Testing::TemplateAssertions, type: type
    config.include ::Rails::Controller::Testing::Integration, type: type
  end
  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true unless meta.key?(:aggregate_failures)
  end
), after: 'RSpec.configure do |config|'

insert_into_file 'spec/rails_helper.rb', "\nrequire 'factory_girl_rails'", after: "require 'rspec/rails'"
run 'rm -rf test'


# Checker ------------------------------------------------------
get 'https://raw.githubusercontent.com/fukuda-free/linux_shell/master/template/.rubocop.yml', '.rubocop.yml'
get 'https://raw.githubusercontent.com/fukuda-free/linux_shell/master/template/.overcommit.yml', '.overcommit.yml'
get 'https://raw.githubusercontent.com/fukuda-free/linux_shell/master/template/.haml-lint.yml', '.haml-lint.yml'


# Guard ------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle install --path vendor/bundle --jobs=4 --without production'
  run 'bundle exec guard init rspec rubocop livereload'
end


# Rubocop Auto correct ------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle exec rubocop --auto-correct'
  run 'bundle exec rubocop --auto-gen-config'
end


# overcommit ------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle exec overcommit --sign'
end


# git commit ------------------------------------------------------
git :commit => "-a -m 'Initial commit'"


# Templates ------------------------------------------------------
file 'app/views/shared/_errors.html.erb', <<-CODE
<% if object.errors.any? %>
  <div class="alert alert-error">
    <a class="close" data-dismiss="alert">&#215;</a>
    <ul>
      <% object.errors.full_messages.each do |msg| %>
        <%= content_tag :li, msg %>
      <% end %>
    </ul>
  </div>
<% end %>
CODE

# add nav bars links
inject_into_file "app/views/layouts/application.html.erb", :after => '<body>' do
  <<-EOS
<%= render "shared/nav" %>
<div class="container">
  <div class="row">
    <div class="col-md-12">
      <%= render "shared/subnav" %>
    </div>
  </div>
  <div class="row">
    <div class="col-md-12">
      <%= render "shared/notice" %>
    </div>
  </div>
  <br>
  <div class="row">
    <div class="col-md-8">
        <%= yield %>
    </div>
    <div class="col-md-4">
        <%= yield :right %>
    </div>
  </div>
</div>
<br>
  EOS
end

#create navs files
file 'app/views/shared/_navs.html.erb', <<-CODE
<nav class="navbar navbar-default" role="navigation">
  <!-- Brand and toggle get grouped for better mobile display -->
  <div class="navbar-header">
    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
      <span class="sr-only">Toggle navigation</span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
    </button>
    <a class="navbar-brand" href="#">Brand</a>
  </div>
  <!-- Collect the nav links, forms, and other content for toggling -->
  <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
    <ul class="nav navbar-nav">
      <li class="active"><%= link_to "Index", root_url %></li>
      <li><%= link_to "Home", home_url %></li>
      <li><%= link_to "about", about_url %></li>
      <li><%= link_to "contact us", contactus_url %></li>
    </ul>
    <form class="navbar-form navbar-left" role="search">
      <div class="form-group">
        <input type="text" class="form-control" placeholder="Search">
      </div>
      <button type="submit" class="btn btn-default">Submit</button>
    </form>
    <ul class="nav navbar-nav navbar-right">
      <% if session[:user_id] %>
      <li class="dropdown">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown">Hi! <%= session[:user_name] %><b class="caret"></b></a>
        <ul class="dropdown-menu">
          <li><%= link_to "Edit", edit_user_url(session[:user_id]) %></li>
          <li><%= link_to "Users", users_url %></li>
          <li class="divider"></li>
          <li><%= link_to "Log-Out", logout_url, method: :delete %></li>
        </ul>
      </li>
      <% else %>
      <li><%= link_to "Sign-in", login_url %></li>
      <li><%= link_to "Sign-up", new_user_url %></li>
      <% end %>
    </ul>
  </div><!-- /.navbar-collapse -->
</nav>
CODE

file 'app/views/shared/_notice.html.erb', <<-CODE
<% flash.each do |name, msg| %>
    <% if msg.is_a?(String) %>
        <div class="alert alert-<%= name == :notice ? 'success' : name == :warning ? 'warning' : 'danger' %>">
          <a class="close" data-dismiss="alert">&#215;</a>
          <%= content_tag :div, msg, :id => "flash_#{name}" %>
        </div>
    <% end %>
<% end %>
CODE

file 'app/views/shared/_subnav.html.erb', <<-CODE
<% if session[:user_id] %>
  <ul class='nav nav-tabs'>
    <li><a href='#'>Welcome</a></li>
    <li><a href='#'>Latest activity</a></li>
    <li <% if controller_name == 'users' %> class='active' <% end %> >users</li>
  </ul>
<% end %>
CODE


# Change css ------------------------------------------------------
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss"


# Initialize Kaminari config ------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle exec rails g kaminari:config'
end


# erb => haml ------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle exec rake haml:replace_erbs'
end


# Rake DB Create ------------------------------------------------------
Bundler.with_clean_env do
  run 'bundle exec rake db:create'
end


# Clean-up ------------------------------------------------------
%w{
  README
  doc/README_FOR_APP
  public/index.html
  app/assets/images/rails.png
}.each { |file| remove_file file }


# Robots ------------------------------------------------------
gsub_file 'public/robots.txt', /# User-Agent/, 'User-Agent'
gsub_file 'public/robots.txt', /# Disallow/, 'Disallow'

# Git ------------------------------------------------------
append_file '.gitignore' do <<-GIT
/public/system
/public/uploads
/coverage
rerun.txt
.rspec
capybara-*.html
.DS_Store
.rbenv-vars
.rbenv-version
GIT
end


# git init ------------------------------------------------------
git :init
git :add => '.'


# docker-compose ------------------------------------------------------
# https://fisaw.online/iiska/rails-templates/blob/master/basic.rb
# ↑サンプル
#
# file 'docker-compose.yml', <<-YML
# version: '3.4'

# volumes:
#   # app_src:
#   bundle_install:
#   db_data:

# services:
#   redis:
#     image: redis
#   db:
#     image: postgres:9.5
#     ports:
#       - "5432:5432"
#     volumes:
#       - pg_data:/var/lib/postgresql/data/pgdata
#     environment:
#       POSTGRES_USER: #{app_name}
#       POSTGRES_PASSWORD: password
#       POSTGRES_DB: #{app_name}_development
#       PGDATA: /var/lib/postgresql/data/pgdata
#   app:
#     build:
#       context: .
#       dockerfile: Dockerfile.dev
#     command: bundle exec rails s -b 0.0.0.0
#     volumes:
#       - .:/app:z
#     ports:
#       - "3000:3000"
#     links:
#       - redis
#       - db
#     environment:
#       - DOCKERIZED=true
# YML

# file 'Dockerfile', <<-DOCKER
# # Build minimal production image. NOTICE that you have to precompile rails assets
# # before building this image.
# #
# #   rails assets:precompile
# FROM ruby:2.4-alpine3.6
# MAINTAINER "#{@maintainer}"
# ENV BUILD_PACKAGES="curl-dev ruby-dev build-base bash zlib-dev libxml2-dev libxslt-dev yaml-dev postgresql-dev" \
#     RUBY_PACKAGES="ruby yaml libstdc++ postgresql-libs libxml2 tzdata"















# gem 'sorcery'
# gem 'simple_form', '~> 3.0.1'
# gem 'ransack', '~> 1.1.0'
# gem 'kaminari', '~> 0.15.1'
# gem 'selenium-webdriver'
# gem 'nokogiri'
# gem 'compass-rails', '~> 1.1.3'
# # gem 'active_decorator', '~> 0.3.4'
# # gem 'active_attr'
# # gem 'delayed_job_active_record', '~> 4.0.0'
# # このへん消しとくとrails4.1でpolyamorousバグに遭遇しない
# gem 'mini_magick'
# gem 'carrierwave'
# # gem 'whenever', require: false if yes?('Use whenever?')

# # gem 'slim'
# # gem 'slim-rails'
# gem 'bootstrap-sass'
# use_bootstrap = true

# gem_group :development, :test do
#   gem 'rspec-rails'
#   gem 'factory_girl_rails'
#   gem 'capybara'
#   gem 'capybara-webkit'
#   gem 'shoulda-matchers'
#   gem 'guard-rspec', require: false
#   gem 'factory_girl_rails'
#   # gem 'parallel_tests'
# end

# gem_group :development do
#   gem 'pry-rails'
#   gem 'better_errors'
#   gem 'letter_opener'
#   gem 'annotate'
#   gem 'thin'
#   gem 'bullet'
#   gem 'quiet_assets'
#   gem 'binding_of_caller'
#   # gem 'html2slim'
# end

# comment_lines 'Gemfile', /gem 'turbolinks'/
# uncomment_lines 'Gemfile', /gem 'therubyracer'/
# gsub_file 'app/views/layouts/application.html.erb', /, "data-turbolinks-track" => true /, ''

# run 'bundle install --path vendor/bundle'

# generate 'kaminari:config'
# generate 'rspec:install'
# remove_dir 'test'

# # run %Q(erb2slim app/views/layouts/application.html.erb app/views/layouts/application.html.slim && rm app/views/layouts/application.html.erb)

# if use_bootstrap
#   generate 'simple_form:install', '--bootstrap'

#   remove_file 'app/assets/stylesheets/application.css'
#   create_file 'app/assets/stylesheets/application.css' do
#     body = <<EOS
# /*
#  *= require_self
#  *= require bootstrap
#  *= require_tree .
#  */
# EOS
#   end
#   gsub_file 'app/assets/javascripts/application.js', /= require turbolinks/, "= require bootstrap"

#   create_file 'app/assets/stylesheets/base.css.scss' do
#      body = <<EOS
# @import "bootstrap";
# EOS
#   end
# else
#   generate 'simple_form:install'
# end



# #gem 'rails_12factor', group: :production

# run "bundle install --path vendor/bundle"
# #use_heroku = true

# #if use_heroku
# #  run 'heroku create --remote staging'
# #  git push: 'staging master  &> /dev/null'
# #end

# # Application settings
# # ----------------------------------------------------------------
# application do
#   %q{
#     config.active_record.default_timezone = :local
#     config.time_zone = 'Tokyo'
#     config.i18n.default_locale = :ja
#     config.generators do |g|
#       g.orm :active_record
#       g.test_framework :rspec, fixture: true, fixture_replacement: :factory_girl
#       g.view_specs false
#       g.controller_specs false
#       g.routing_specs false
#       g.helper_specs false
#       g.request_specs false
#       g.assets false
#       g.helper false
#     end
#     config.autoload_paths += %W(#{config.root}/lib)
#   }
# end

# # Environment setting
# # ----------------------------------------------------------------
# comment_lines 'config/environments/production.rb', "config.serve_static_assets = false"
# environment 'config.serve_static_assets = true', env: 'production'
# environment 'config.action_mailer.delivery_method = :letter_opener', env: 'development'


# # .gitignore settings
# # ----------------------------------------------------------------
# remove_file '.gitignore'
# create_file '.gitignore' do
#   body = <<EOS
# /.bundle
# /vendor/bundle
# /db/*.sqlite3
# /db/schema.rb
# /log/*.log
# /tmp
# .DS_Store
# /public/assets*
# /config/database.yml
# newrelic.yml
# .foreman
# .env
# doc/
# *.swp
# *~
# .project
# .idea
# .secret
# /*.iml
# *.rbc
# capybara-*.html
# .rspec
# /public/system
# /coverage/
# /spec/tmp
# **.orig
# rerun.txt
# pickle-email-*.html
# config/initializers/secret_token.rb
# config/secrets.yml
# .rvmrc
# EOS
# end

# # Root path settings
# # ----------------------------------------------------------------
# generate 'controller', 'home index'
# route "root to: 'home#index'"



# # Create directories
# # ----------------------------------------------------------------
# empty_directory 'app/decorators'
# create_file 'app/decorators/.gitkeep'

# # DB
# # ----------------------------------------------------------------
# run 'be rake db:create'
# run 'be rake db:migrate'

# # Parallel test
# # ----------------------------------------------------------------
# # rake 'parallel:create'
# # rake 'parallel:prepare'

# # GuardとFactoryGirlの設定もしたい
# # spec_helper.rb
# # config.include FactoryGirl::Syntax::Methods

# # git
# # ----------------------------------------------------------------
# git :init
# git add: ".  &> /dev/null"
# git commit: %Q{ -m 'Initial commit' &> /dev/null }

# exit
