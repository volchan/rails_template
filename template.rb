require 'fileutils'
require 'shellwords'
require 'tmpdir'

RAILS_REQUIREMENT = '>= 5.2.1'.freeze

def apply_template!
  assert_minimum_rails_version
  assert_pg
  add_template_repository_to_source_path
  clean_gemfile
  ask_optional_gems
  check_webpack
  add_optional_gems
  apply 'config/template.rb'
  apply 'app/template.rb'
  copy_file 'Procfile'
  after_bundle do
    setup_gems
    js_setup
    setup_overcommit
    setup_active_storage if @storage
    run 'rails db:create db:migrate'
    copy_file 'Rakefile', force: true
    template 'README.md.tt', force: true
    initial_commit
    push_github if @github
  end
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  # ask_to_continue(rails_version)
  puts "Please install rails #{RAILS_REQUIREMENT}!"
  delete_app
  exit 1
end

def delete_app
  run "rm -rf ../#{app_name}"
end

def assert_pg
  return if options['database'] == 'postgresql'

  puts 'Please add "-d postgresql" as an option!'
  delete_app
  exit 1
end

# def ask_to_continue(rails_version)
#   prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
#            "You are using #{rails_version}. continue, update or quit ? (c/u/q)"
#   res = ask?(prompt).downcase
#
#   return if %(c continue).include?(res)
#   return update_rails if %(u update).include?(res)
#   return exit 1 if %(q quit exit).include?(res)
#
#   puts 'I don\'t understand your answer sorry.'
#   ask_to_continue
# end
#
# def update_rails
#   run 'gem update rails'
# end

def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    source_paths.unshift(tempdir = Dir.mktmpdir('rails-template-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/volchan/rails_template',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{rails_template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def clean_gemfile
  template 'Gemfile.tt', force: true
end

def ask_optional_gems
  @no_webpack = yes?('Are you sure you don\'t want webpack? (y/n)', :red) unless options['webpack']
  @pundit = yes?('Do you want to manage authorizations with Pundit? (y/n)', :green)
  @haml = yes?('Do you want to use Haml instead of ERB? (y/n)', :green)
  @storage = yes?('Do you want to use ActiveStorage? (y/n)', :green)
  @aws = yes?('Do you want to use amazon S3 with ActiveStorage? (y/n)', :green) if @storage
  @cloudinary = yes?('Do you want to use cloudinary with ActiveStorage? (y/n)', :green) unless @aws
  @github = yes?('Do you want to push your project to Github? (y/n)', :green)
end

def check_webpack
  return if @no_webpack
  delete_app
  exit 1
end

def add_optional_gems
  add_pundit if @pundit
  add_haml if @haml
  add_aws if @aws
  add_cloudinary if @cloudinary
end

def add_pundit
  insert_into_file 'Gemfile', "gem 'pundit'\n", after: /'puma'\n/
end

def add_haml
  insert_into_file 'Gemfile', "gem 'haml'\n", after: /'font-awesome-sass', '~> 5.3.1'\n/
  insert_into_file 'Gemfile', "gem 'haml-rails', '~> 1.0'\n", after: /'haml'\n/
end

def add_aws
  insert_into_file 'Gemfile', "gem 'aws-sdk-s3'\n", after: /'autoprefixer-rails'\n/
end

def add_cloudinary
  insert_into_file 'Gemfile', "gem 'cloudinary', require: false\n", before: /gem 'country_select'\n/
  insert_into_file 'Gemfile', "gem 'activestorage-cloudinary-service'\n", before: /gem 'autoprefixer-rails'\n/
end

def initial_commit
  git add: '.'
  git commit: %( -m 'Initial commit' )
end

def js_setup
  return unless options['webpack']

  run 'yarn add --dev babel-eslint eslint eslint-config-airbnb-base eslint-config-prettier eslint-import-resolver-webpack eslint-plugin-import eslint-plugin-prettier lint-staged prettier stylelint stylelint-config-standard' if File.exist?('package.json')
  copy_file '.eslintrc'
  copy_file '.eslintignore'
  copy_file '.stylelintrc'
  run 'yarn add normalize.css lodash'
end

def setup_gems
  setup_annotate
  setup_erd
  setup_sidekiq
  setup_rubocop
  setup_brakeman
  setup_devise
  setup_simple_form
  setup_pundit if @pundit
  setup_haml if @haml
end

def setup_annotate
  run 'rails g annotate:install'
end

def setup_erd
  run 'rails g erd:install'
  append_to_file '.gitignore', 'erd.pdf'
end

def setup_sidekiq
end

def setup_rubocop
  copy_file '.rubocop.yml'
end

def setup_brakeman
end

def setup_devise
  copy_file 'config/routes.rb', force: true
  run 'rails g devise:install'
  run 'rails g devise:i18n:views'
  insert_into_file 'config/initializers/devise.rb', "  config.secret_key = Rails.application.credentials.secret_key_base\n", before: /^end/
  run 'rails g devise User'
  insert_into_file 'config/routes.rb', before: '  devise_for :users' do
    <<-RUBY
  require 'sidekiq/web'
  require 'sidekiq-status/web'

  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end
    RUBY
  end
end

def setup_simple_form
  run 'rails g simple_form:install --bootstrap'
end

def setup_pundit
  insert_into_file 'app/controllers/application_controller.rb', before: /^end/ do
    <<-RUBY
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_path)
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
    RUBY
  end
  insert_into_file 'app/controllers/application_controller.rb', after: /exception\n/ do
    <<-RUBY
  include Pundit
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    RUBY
  end
  run 'spring stop'
  run 'rails g pundit:install'
end

def setup_haml
  run 'HAML_RAILS_DELETE_ERB=true rake haml:erb2haml'
end

def push_github
  run 'hub create'
  run 'git push origin master'
  run 'git push origin develop'
end

def setup_overcommit
  run 'overcommit --install'
  copy_file '.overcommit.yml', force: true
  run 'overcommit --sign'
end

def setup_active_storage
  run 'rails active_storage:install'
  copy_file 'config/storage.yml', force: true
  aws_config if @aws
  cloudinary_config if @cloudinary
end

def aws_config
  gsub_file 'config/environments/production.rb', /config.active_storage.service = :local/, 'config.active_storage.service = :amazon'
  insert_into_file 'config/storage.yml', after: '  root: <%= Rails.root.join("storage") %>' do
    <<-YML
\n
amazon:
  service: S3
  access_key_id: <%= 'Your amazon S3 access_key_id goes here!' %> # Put the actual key in your Environment viriables!!!!!!!
  secret_access_key: <%= 'Your amazon S3 secret_access_key goes here!' %> # Put the actual key in your Environment viriables!!!!!!!
  region: Your amazon S3 bucket region goes here!
  bucket: Your amazon S3 bucket name goes here!
    YML
  end
end

def cloudinary_config
  gsub_file 'config/environments/production.rb', /config.active_storage.service = :local/, 'config.active_storage.service = :cloudinary'
  insert_into_file 'config/storage.yml', after: '  root: <%= Rails.root.join("storage") %>' do
    <<-YML
\n
cloudinary:
  service: Cloudinary
  cloud_name: <%= 'Your Cloudinary cloud name goes here!' %> # Put the actual key in your Environment viriables!!!!!!!
  api_key: <%= 'Your Cloudinary api key goes here!' %> # Put the actual key in your Environment viriables!!!!!!!
  api_secret: <%= 'Your Cloudinary api secret goes here!' %> # Put the actual key in your Environment viriables!!!!!!!
    YML
  end

end

run 'pgrep spring | xargs kill -9'
apply_template!
