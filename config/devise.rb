def mailer_config
  "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }"
end

environment mailer_config, env: 'development' if @devise
