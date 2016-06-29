source 'https://rubygems.org'

ruby '2.1.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'angular-rails-templates'
gem 'responders'
gem 'devise', '~> 3.4.0'
gem 'angular_rails_csrf'

# all things authorization
gem 'cancancan'

# separates serialized models from rails models
gem 'active_model_serializers'


# file attachment management
gem 'paperclip'

# complex object cloning
gem 'amoeba', '~> 3.0.0'

# deployment
gem 'rails_12factor'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # nice rails console printing: "ap User.all"
  gem 'awesome_print'

  # nicer test runners + color output
  gem 'minitest-reporters'
end

group :production do
  gem 'therubyracer',  platforms: :ruby
  gem 'mysql2'
end

gem 'tzinfo-data'
