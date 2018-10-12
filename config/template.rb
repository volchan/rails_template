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

copy_file 'config/sidekiq.yml'
copy_file 'config/initializers/redis.rb'
environment mailer_config, env: 'development'
environment bullet_config, env: 'development'
