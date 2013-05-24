source "http://rubygems.org"

gem "activerecord", ENV['AGAINST'] || "< 4.0" 
gem "actionpack",   ENV['AGAINST'] || "< 4.0" 
gem "fastercsv" unless RUBY_VERSION > "1.9"

group :development do
  gem 'rake'
  gem "rspec", ">= 1.2.9"
  gem "rdoc", "~> 3.12"
  gem "bundler", ">= 1.0.0"
  gem "jeweler", "~> 1.8.3"
  gem 'simplecov', :require => false
  gem 'sqlite3'
  gem 'mysql2', '0.2.7'
  gem 'awesome_print'
  gem 'guard'
  gem "guard-shell", "~> 0.5.1"
  gem 'rb-fsevent', '~> 0.9'
  gem 'rb-readline'
end
