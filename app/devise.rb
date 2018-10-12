insert_into_file(
  'app/controllers/application_controller.rb',
  ' before_action :authenticate_user!',
  after: /'before_action :set_locale'\n/
)

insert_into_file(
  'app/controllers/pages_controller.rb',
  ' skip_before_action :authenticate_user!, only: %I[home]',
  after: /'class PagesController < ApplicationController'\n/
)
