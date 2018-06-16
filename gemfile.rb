run 'rm Gemfile'
file 'Gemfile', <<~RUBY
  source 'https://rubygems.org'

  ruby '#{RUBY_VERSION}'

  gem 'autoprefixer-rails'
  gem 'bootsnap', require: false
  gem 'bootstrap'
  gem 'font-awesome-sass', '~> 5.0.9'
  gem 'jbuilder', '~> 2.0'
  gem 'pg', '~> 0.21'
  gem 'pry-rails'
  gem 'puma'
  gem 'rails', '#{Rails.version}'
  gem 'redis'
  gem 'sass-rails'
  gem 'simple_form'
  gem 'uglifier'
  gem 'webpacker'

  group :development do
  gem 'annotate'
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'overcommit'
  gem 'pry-byebug'
  gem 'rails-erd'
  gem 'rubocop', require: false
  gem 'table_print'
  gem 'web-console', '>= 3.3.0'
  gem 'xray-rails'
  end

  group :development, :test do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  end
RUBY
