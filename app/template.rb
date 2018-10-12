copy_file 'app/controllers/application_controller.rb', force: true
copy_file 'app/controllers/pages_controller.rb'
copy_file 'app/views/layouts/application.html.erb', force: true
copy_file 'app/views/pages/home.html.erb'

if @devise
  insert_into_file(
    'app/controllers/application_controller.rb',
    ' before_action :authenticate_user!',
    after: "  before_action :set_locale\n"
  )

  inject_into_class(
    'app/controllers/pages_controller.rb',
    PagesController,
    " skip_before_action :authenticate_user!, only: %I[home]\n"
  )
end
