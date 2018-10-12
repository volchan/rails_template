def bullet_config
  'config.after_initialize do
    Bullet.enable        = true
    Bullet.bullet_logger = true
    Bullet.console       = true
    Bullet.rails_logger  = true
  end'
end

copy_file 'config/sidekiq.yml'
copy_file 'config/initializers/redis.rb'
environment bullet_config, env: 'development'
