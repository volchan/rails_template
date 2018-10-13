def bullet_config
  <<~RUBY
    config.after_initialize do
      Bullet.enable        = true
      Bullet.bullet_logger = true
      Bullet.console       = true
      Bullet.rails_logger  = true
    end
  RUBY
end

def mailer_config
  "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }"
end

copy_file 'config/initializers/i18n.rb'
copy_file 'config/initializers/sidekiq.rb'
copy_file 'config/initializers/redis.rb'
copy_file 'config/sidekiq.yml'
remove_file 'config/locales/en.yml'
copy_file 'config/locales/defaults/en.yml'
copy_file 'config/locales/models/en.yml'
copy_file 'config/locales/views/en.yml'
copy_file 'config/locales/defaults/fr.yml'
copy_file 'config/locales/models/fr.yml'
copy_file 'config/locales/views/fr.yml'

environment mailer_config, env: 'development'
environment bullet_config, env: 'development'
