require 'fileutils'
require 'shellwords'
require 'tmpdir'
require 'pry-byebug'

RAILS_REQUIREMENT = '>= 5.2.1'.freeze

def apply_template!
  assert_minimum_rails_version
  add_template_repository_to_source_path
  clean_gemfile
  ask_optional_gems
  install_optional_gems
  apply 'config/template.rb'
  apply 'app/template.rb'
  initial_commit
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  ask_to_continue
end

def ask_to_continue
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
  @haml = yes?('Do you want to use Haml instead of EBR? (y/n)')
  @github = yes?('Do you want to push your project to Github? (y/n)')
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
  insert_into_file 'Gemfile', "gem 'haml'\n", after: /'font-awesome-sass', '~> 5.0.9'\n/
  insert_into_file 'Gemfile', "gem 'haml-rails', git: 'git://github.com/indirect/haml-rails.git'\n", after: /'haml'\n/
end

def initial_commit
  git add: '.'
  git commit: "-m 'Initial commit'"
end

run 'pgrep spring | xargs kill -9'
apply_template!
