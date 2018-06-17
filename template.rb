require 'fileutils'
require 'shellwords'
require 'tmpdir'
require 'pry-byebug'

RAILS_REQUIREMENT = '>= 5.2.0'.freeze

def apply_template!
  assert_minimum_rails_version
  add_template_repository_to_source_path
  clean_gemfile
  ask_optional_gems
  install_optional_gems
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway? (y/n)"
  exit 1 if no?(prompt)
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
  @pundit = yes?('Do you want to manage authorizations with Pundit? (y/n)') if @devise
  @haml = yes?('Do you want to use Haml instead of EBR? (y/n)')
  @github = yes?('Do you want to push your project to Github? (y/n)')
end

def install_optional_gems
  add_devise if @devise
  add_pundit if @pundit
  add_haml if @haml
end

def add_devise
  insert_into_file 'Gemfile', "gem 'devise'\n", after: /'bootstrap'\n/
  insert_into_file 'Gemfile', "gem 'devise-i18n'\n", after: /'devise'\n/
end

def add_pundit
  insert_into_file 'Gemfile', "gem 'pundit'\n", after: /'puma'\n/
end

def add_haml
  insert_into_file 'Gemfile', "gem 'haml'\n", after: /'font-awesome-sass', '~> 5.0.9'\n/
  insert_into_file 'Gemfile', "gem 'haml-rails', git: 'git://github.com/indirect/haml-rails.git'\n", after: /'haml'\n/
end

run 'pgrep spring | xargs kill -9'
apply_template!
