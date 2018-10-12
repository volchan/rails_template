require 'fileutils'
require 'shellwords'
require 'tmpdir'

RAILS_REQUIREMENT = '>= 5.2.1'.freeze

def apply_template!
  assert_minimum_rails_version
  add_template_repository_to_source_path
  clean_gemfile
  ask_optional_gems
  install_optional_gems
  apply 'config/template.rb'
  apply 'app/template.rb'
  after_bundle do
    run_gem_setups
    js_setup
    initial_commit
  end
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  ask_to_continue(rails_version)
end

def ask_to_continue(rails_version)
  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. continue, update or quit ? (c/u/q)"
  res = ask?(prompt).downcase

  return if %(c continue).include?(res)
  return update_rails if %(u update).include?(res)
  return exit 1 if %(q quit exit).include?(res)

  puts 'I did not understand your answer sorry.'
  ask_to_continue
end

def update_rails
  run 'gem update rails'
end

def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    source_paths.unshift(tempdir = Dir.mktmpdir('rails-template-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/volchan/rails_template',
      tempdir
    ].map(&:shellescape).join(' ')
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def clean_gemfile
  template 'Gemfile.tt', force: true
end

def ask_optional_gems
  @devise = yes?('Do you want to implement authentication in your app with the Devise gem? (y/n)')
  @pundit = yes?('Do you want to manage authorizations with Pundit? (y/n)')
  @sidekiq = yes?('Do you want to use redis and sidekiq for background jobs? (y/n)')
  @haml = yes?('Do you want to use Haml instead of ERB? (y/n)')
  @github = yes?('Do you want to push your project to Github? (y/n)')
  @hub = yes?('Do you have the hub cli? (y/n)')
end

def install_optional_gems
  add_devise if @devise
  add_pundit if @pundit
  add_sidekiq if @sidekiq
  add_haml if @haml
end

def add_devise
  insert_into_file 'Gemfile', "gem 'devise'\n", after: /'country_select'\n/
  insert_into_file 'Gemfile', "gem 'devise-i18n'\n", after: /'devise'\n/
end

def add_pundit
  insert_into_file 'Gemfile', "gem 'pundit'\n", after: /'puma'\n/
end

def add_sidekiq
  insert_into_file 'Gemfile', "gem 'sidekiq'\n", after: /'sass-rails'\n/
  insert_into_file 'Gemfile', "gem 'sidekiq-failures', '~> 1.0'\n", after: /'sidekiq'\n/
  insert_into_file 'Gemfile', "gem 'sidekiq-status'\n", after: /gem 'sidekiq-failures', '~> 1.0'\n/
end

def add_haml
  insert_into_file 'Gemfile', "gem 'haml', '~> 1.0'\n", after: /'font-awesome-sass', '~> 5.0.9'\n/
  insert_into_file 'Gemfile', "gem 'haml-rails', git: 'git://github.com/indirect/haml-rails.git'\n", after: /'haml'\n/
end

def initial_commit
  git add: '.'
  git commit: %( -m 'Initial commit' )
end

def run_gem_setups
  run 'rails generate devise:install' if @devise
  run 'rails generate devise User' if @devise
  run 'rails generate simple_form:install --bootstrap'
  run 'rails g devise:i18n:views' if @devise
  run 'HAML_RAILS_DELETE_ERB=true rake haml:erb2haml' if @haml
  copy_file '.rubocop.yml'
  copy_file '.overcommit.yml'
end

def js_setup
  run 'yarn add --dev babel-eslint eslint eslint-config-airbnb-base eslint-config-prettier eslint-import-resolver-webpack eslint-plugin-import eslint-plugin-prettier lint-staged prettier stylelint stylelint-config-standard' if File.exist?('package.json')
end

run 'pgrep spring | xargs kill -9'
apply_template!
