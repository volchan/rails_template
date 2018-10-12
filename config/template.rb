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

copy_file 'config/sidekiq.yml' if @sidekiq
copy_file 'config/initializers/redis.rb' if @sidekiq
environment mailer_config, env: 'development' if @devise
environment bullet_config, env: 'development'
