copy_file 'config/sidekiq.yml'
copy_file 'config/initializers/redis.rb'
environment "config.after_initialize do\n
  Bullet.enable        = true\n
  Bullet.bullet_logger = true\n
  Bullet.console       = true\n
  Bullet.rails_logger  = true\n
end\n", env: 'development'
