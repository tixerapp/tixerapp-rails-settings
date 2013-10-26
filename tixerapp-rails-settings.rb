require 'yaml'

cwd = File.dirname(File.expand_path(__FILE__))

remove_dir 'log'
remove_dir 'tmp'
remove_dir 'test'

remove_file 'README.rdoc'
remove_file '.gitignore'

gsub_file 'config/environments/production.rb',
          /config.serve_static_assets = (.*)/,
          "config.serve_static_assets = true"

secret_token = "File.join(File.dirname(__FILE__), '..', 'security_token')"

gsub_file 'Gemfile',
          /#(.*)$/,
          ''

gsub_file 'Gemfile',
          /^\s+?\n?\s+?\n?/,
          ''

gsub_file 'Gemfile',
          /gem 'sass-rails'(.+)$/,
          "gem 'sass-rails'"

gsub_file 'Gemfile',
          /gem 'coffee-rails'(.+)$/,
          "gem 'coffee-rails'"

gsub_file 'config/initializers/secret_token.rb',
          /config.secret_key_base = (.+)$/,
          "config.secret_key_base = File.exists?(#{secret_token}) ? File.read(#{secret_token}).strip : ENV['SECRET_TOKEN']"

run 'rake secret >> config/security_token'

copy_file cwd + '/public/config/database.yml',
          'config/database.yml.sample'
run 'cp config/database.yml config/database.yml.project'
run 'cp config/database.yml.sample config/database.yml'

run '$EDITOR config/database.yml'
rake 'db:drop:all'
rake 'db:create:all'

rake 'db:migrate RAILS_ENV=production'
rake 'db:migrate RAILS_ENV=development'
rake 'db:migrate RAILS_ENV=test'

gem 'unicorn'
gem 'unicorn-rails'

gem 'foreman'
copy_file cwd + '/public/Procfile', 'Procfile'
copy_file cwd + '/public/env', '.env'

gem 'rails_12factor'

run 'bundle install'

gem 'rubocop', group: :development, require: false
gem 'better_errors', group: :development
gem 'binding_of_caller', group: :development
gem 'ruby_gntp', group: :development
gem 'bullet', group: :development

copy_file cwd + '/public/config/initializers/bullet.rb',
          'config/initializers/bullet.rb'

gem 'sqlite3-ruby', group: [:development, :test], require: false
gem 'ruby_parser', group: [:development, :test]
gem 'mailcatcher', group: [:development, :test], require: false

gem 'rspec', group: [:development, :test]
gem 'rspec-rails', group: [:development, :test]
gem 'factory_girl_rails', group: [:development, :test]
gem 'ffaker', group: [:development, :test]
gem 'webrat', group: [:development, :test]
gem 'capybara', group: [:development, :test]
gem 'launchy', group: [:development, :test]
gem 'database_cleaner', group: [:development, :test]

run 'bundle install'

generate 'rspec:install'

inject_into_file '.rspec', after: '--color' do
<<-TEXT
 --format documentation
TEXT
end

inject_into_file 'spec/spec_helper.rb', before: "RSpec.configure do |config|" do
<<-TEXT

Webrat.configure do |config|
  config.mode = :rack
end

TEXT
end

inject_into_file 'spec/spec_helper.rb', after: "# config.mock_with :rr" do
<<-TEXT

  config.include FactoryGirl::Syntax::Methods
  config.include Webrat::Methods

TEXT
end

inject_into_file 'spec/spec_helper.rb', after: "require 'rspec/autorun'" do
<<-TEXT

require 'capybara/rspec'
require 'database_cleaner'
TEXT
end

gem 'composite_primary_keys'
gem 'foreigner'
gem 'awesome_nested_set'
gem 'paperclip'
gem 'image_sorcery'
gem 'nokogiri'
gem 'state_machine'
gem 'globalize3'
gem 'simple_form'
gem 'country_select'
gem 'kaminari'
gem 'rabl'
gem 'activemerchant'

run 'bundle install'

generate 'simple_form:install'
generate 'kaminari:config'

gem 'bcrypt-ruby'
gem 'devise'
gem 'devise-encryptable'
gem 'cancan'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'

run 'bundle install'

generate 'devise:install'

devise_pepper = "File.join(File.dirname(__FILE__), '..', 'devise_pepper')"

gsub_file 'config/initializers/devise.rb',
          /please-change-me-at-config-initializers-devise@example.com/,
          'hagarvikingo@icloud.com'
gsub_file 'config/initializers/devise.rb',
          '# config.authentication_keys = [ :email ]',
          'config.authentication_keys = [ :email ]'
gsub_file 'config/initializers/devise.rb',
          '# config.paranoid = true',
          'config.paranoid = true'
gsub_file 'config/initializers/devise.rb',
          /# config.pepper(.*)/,
          "config.pepper = File.exists?(#{devise_pepper}) ? File.read(#{devise_pepper}).strip : ENV['SECRET_TOKEN']"
gsub_file 'config/initializers/devise.rb',
          '# config.confirmation_keys = [ :email ]',
          'config.confirmation_keys = [ :email ]'
gsub_file 'config/initializers/devise.rb',
          /# config.remember_for = 2.weeks/,
          'config.remember_for = 4.weeks'
gsub_file 'config/initializers/devise.rb',
          /# config.confirm_within = 3.days/,
          'config.confirm_within = 3.days'
gsub_file 'config/initializers/devise.rb',
          /config.password_length = 8..128/,
          'config.password_length = 4..128'
gsub_file 'config/initializers/devise.rb',
          /# config.timeout_in = 30.minutes/,
          'config.timeout_in = 2.hours'
gsub_file 'config/initializers/devise.rb',
          /# config.lock_strategy = :failed_attempts/,
          'config.lock_strategy = :failed_attempts'
gsub_file 'config/initializers/devise.rb',
          /# config.maximum_attempts = 20/,
          'config.maximum_attempts = 5'
gsub_file 'config/initializers/devise.rb',
          /# config.encryptor = :sha512/,
          'config.encryptor = :sha512'
gsub_file 'config/initializers/devise.rb',
          /# config.token_authentication_key = :auth_token/,
          'config.token_authentication_key = :auth_token'
run 'rake secret > config/devise_pepper'

inject_into_file 'config/environments/development.rb',
                 after: 'config.action_mailer.raise_delivery_errors = false' do
<<-EOS

  config.action_mailer.default_url_options = { host: '0.0.0.0:5000' }
EOS
end

inject_into_file 'app/controllers/application_controller.rb',
                 after: 'protect_from_forgery with: :exception' do
<<-TEXT


  # before_filter :authenticate_user!, :set_current_user
  around_filter :enable_request_on_models!

  def enable_request_on_models!
    method_for_request = instance_variable_get(:"@_request")

    ActiveRecord::Base.send(:define_method,
                            'request',
                            proc { method_for_request })
    ActiveRecord::Base.class.send(:define_method,
                                  'request',
                                  proc { method_for_request })
    yield
    ActiveRecord::Base.send :remove_method, 'request'
    ActiveRecord::Base.class.send :remove_method, 'request'
  end

  # Put this in your models!
  # def set_current_user!
  #   self.user_id ||= Thread.current[:user].id
  # end

  #def set_current_user
  #  Thread.current[:user] = current_user
  #end
TEXT
end

inject_into_file 'config/application.rb',
                 after: 'config.i18n.default_locale = :de' do
<<-TEXT

    # Customize generators

    config.generators do |g|
      g.stylesheets true
      g.javascripts true
      g.helper true
      g.test_framework :rspec,
        fixtures: true,
        view_specs: true,
        helper_specs: true,
        routing_specs: true,
        controller_specs: true,
        request_specs: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end
TEXT
end

gem 'premailer-rails'
gem 'mail'
gem 'daemons'
gem 'pony'
gem 'httparty', require: false

gem 'whenever', require: false
gem 'faye'
gem 'thin'
gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'

run 'bundle install'

run 'wheneverize .'

copy_file cwd + '/public/faye.ru', 'faye.ru'
copy_file cwd + '/public/config/faye.yml', 'config/faye.yml'
copy_file cwd + '/public/config/initializers/faye.rb', 'config/initializers/faye.rb'

empty_directory 'app/workers'
copy_file cwd + '/public/sidekiq.ru', 'sidekiq.ru'

copy_file cwd + '/public/gitignore', '.gitignore'

generate "devise User treatment:string first_name:string last_name:string nick_name:string date_of_birth:date avatar:has_attached_file"
generate "scaffold Organization name:string kind:string website:string content:string address:text avatar:has_attached_file lat:float lng:float"
generate "scaffold Timeline user:references route:string content:text hidden:boolean"
generate "scaffold Study user:references organization:references degree:string content:text started_at:date finished_at:date is_current:boolean"
generate "scaffold Job user:references organization:references position:string content:text started_at:date finished_at:date is_current:boolean"
generate "scaffold Publication user:references organization:references title:text content:text published_at:date"
generate "scaffold Recommendation user:references recommender:references content:text accepted:boolean"
generate "scaffold Respect user:references colleague:references blocked:boolean"
generate "scaffold Colleague follower:references following:references accepted:boolean follower_blocked:boolean following_blocked:boolean"
generate "scaffold Chat sender:references recipient:references content:text read:boolean"
generate "scaffold Topic name:string"
generate "scaffold Level name:string"
generate "scaffold Question user:references topic:references name:string content:text status:string"
generate "scaffold Answer user:references question:references content:string"
generate "scaffold Document user:references topic:references level:references name:string kind:string content:text"
generate "scaffold Bookmark user:references document:references note:text"
generate "scaffold Revision user:references document:references content:has_attached_file mimetype:string"
generate "scaffold Comment document:references user:references content:text"
generate "scaffold Activity user:references name:string website:string content:string avatar:has_attached_file address:text started_at:datetime finished_at:datetime privacy:string"
generate "scaffold Attendance user:references activity:references rsvp:string"

git :init
git add: '.'
git commit: "-a -m 'Initializing Application Structure'"

run 'heroku create tixerapp'
run 'heroku config:set SECRET_TOKEN=$(rake secret)'
run 'heroku config:set DEVISE_PEPPER=$(rake secret)'
