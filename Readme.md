# Modern Rails Template

## Description

This is the rails template I used for my Rails 5.2 projects as a freelance developer. Its goal is to allow to begin new rails application easily, with a modern and efficient configuration and with good set of defaults. The project is still very much a work in progress. So do not expect it to be 100% bug free. [Contributions][], ideas and help are really welcome.

This project is inspired by the template developed by Matt Brictson. Have a look [here][] to compare both.

## Requirements

This template currently works with:

* Rails 5.2.x
* PostgreSQL

## Installation

_Optional._

To make this the default Rails application template on your system, create a `~/.railsrc` file with these contents:

```
--skip-coffee
--webpack
-d postgresql
-T
-m https://raw.githubusercontent.com/volchan/rails_template/master/template.rb
```

## Usage

To generate a Rails application using this template, pass the options below to `rails new`, like this:

```
rails new blog \
  --skip-coffee \
  --webpack \
  -d postgresql \
  -T \
  -m https://raw.githubusercontent.com/volchan/rails_template/master/template.rb
```

_Remember that options must go after the name of the application._ The only database supported by this template is `postgresql`.

If you’ve installed this template as your default (using `~/.railsrc` as described above), then all you have to do is run:

```
rails new blog
```

## What does it do?

The template will perform the following steps:

1. Ask for which option you want in this project
1. Generate your application files and directories
1. Add useful gems and good configs
1. Add the optional config specified
1. Commit everything to git

## What is included?

Below is an extract of what this generator does. You can check all the features by following the code, especially in `template.rb` and in the `Gemfile`.

### Standard configuration

* Setup [I18n][] for English and French
* Improve the main layout (cf `app/views/layouts/application.haml.erb`) to include webpack in the asset pipeline
* Create a basic PagesController to have something to show when the app launch
* Add a [Procfile][] to prepare for heroku deployment.
* Add Javascript ([ESLint][]) and CSS ([Stylelint][]) linters with webpack
* Add and configure the [annotate][] gem to add useful comments in our models
* Add and configure the [bullet][] gem to track N+1 queries
* Add and configure the [rails_erd][] gem to generate automatically a schema of our database relationships
* Add and configure the [sidekiq][] gem for background jobs. You can access the sidekiq dashboard in the app at `/sidekiq`(route restricted to admin only).
* Add and configure the [sidekiq-status][] gem for tracking background jobs statuses, just add `include Sidekiq::Status::Worker` in the jobs you wan't to track.
* Add and configure [rubocop][] for style and [brakeman][] for security and add them to [overcommit][] git hooks
* Add [better-errors][] and [xray-rails][] for easier debugging
* Add [awesome-print][] and [table-print][] for easier exploration in the terminal

### Additional options

When you launch a new rails app with the template, a few questions will be asked. Answer 'y' or 'yes' to unable the given option.

* If need authorization, [pundit][] can be added and configured too.
* You can choose to use [Haml][] instead of `erb`.
* You can choose to use [ActiveStorage][].
* You can cheese to use either [Amazon S3][] or [Cloudinary][] as service for [ActiveStorage][].
* Finally, you can choose to create a Github repository for you project and push it directly.

## How does it work?

This project works by hooking into the standard Rails application templates system, with some caveats. The entry point is the `template.rb` file in the root of this repository.

Normally, Rails only allows a single file to be specified as an application template (i.e. using the `-m <URL>` option). To work around this limitation, the first step this template performs is a `git clone` of the `damienlethiec/modern-rails-template` repository to a local temporary directory.

This temporary directory is then added to the `source_paths` of the Rails generator system, allowing all of its ERb templates and files to be referenced when the application template script is evaluated.

Rails generators are very lightly documented; what you’ll find is that most of the heavy lifting is done by [Thor][]. The most common methods used by this template are Thor’s `copy_file`, `template`, and `gsub_file`.

## Contributing

If you want to contribute, please have a look to the issues in this repository and pick one you are interested in. You can then clone the project and submit a pull request. We also happily welcome new idea and, of course, bug reports.

[thor]: https://github.com/erikhuda/thor
[here]: https://github.com/mattbrictson/rails-template
[contributions]: https://github.com/volchan/rails_template#contributing
[procfile]: https://devcenter.heroku.com/articles/procfile
[i18n]: http://guides.rubyonrails.org/i18n.html
[eslint]: https://eslint.org/
[stylelint]: https://stylelint.io/
[friendly_id]: https://github.com/norman/friendly_id
[annotate]: https://github.com/ctran/annotate_models
[bullet]: https://github.com/flyerhzm/bullet
[rails_erd]: https://github.com/voormedia/rails-erd
[sidekiq]: https://github.com/mperham/sidekiq
[sidekiq-status]: https://github.com/utgarda/sidekiq-status
[rubocop]: http://rubocop.readthedocs.io/en/latest/
[brakeman]: https://brakemanscanner.org/
[overcommit]: https://github.com/brigade/overcommit
[better-errors]: https://github.com/charliesome/better_errors
[xray-rails]: https://github.com/brentd/xray-rails
[awesome-print]: https://github.com/michaeldv/awesome_print
[table-print]: https://github.com/arches/table_print
[git-flow]: https://github.com/nvie/gitflow
[devise]: https://github.com/plataformatec/devise
[pundit]: https://github.com/varvet/pundit
[haml]: http://haml.info/
[activestorage]: https://guides.rubyonrails.org/active_storage_overview.html
[amazon_s3]: https://aws.amazon.com/s3
[cloudinary]: https://github.com/0sc/activestorage-cloudinary-service
