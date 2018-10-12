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

exit 1 if @devise
environment bullet_config, env: 'development'
