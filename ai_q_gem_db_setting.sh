echo ''
echo ''
echo 'AIQのgem設定'
echo ''
echo ''
cd /var/www/rails/ai_q
bundle install --path vendor/bundle --jobs=4
# bundle exec gem uninstall okuribito_rails
# rm -rf config/okuribito.yml
RAILS_ENV=development bundle exec rake db:create
RAILS_ENV=development bundle exec rake db:migrate
bundle exec rails runner lib/console/share/recreate_common_db.rb
bundle exec rails runner lib/console/share/reload_sys_config_db_seed.rb
bundle exec rails runner lib/console/share/create_test_company.rb -c 5 -a 10 -u 10
bundle exec rake bower:install['--allow-root']
