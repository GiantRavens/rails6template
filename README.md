Rails 6 Template
================

Clone the repo, run `bundle install` and `yarn` - or follow along as we build the template atomically.

__Install local gems__

Install mailcatcher with:

`gem install mailcatcher`

You can start it with just `mailcatcher` - it runs a local webserver at localhost:1080 and catches SMTP locally at :1025

Make sure that you can build the pg gem properly:

`gem install pg`

If not, install the Postgres headers. On a Mac the fastest way to do this is install Postgres itself:

`brew install postgres`

For running Postgres locally on a Mac try the Postgres.app

__Start your app and test that Rails is running properly__

Create your new rails project and specify PostgreSQL as your database:

`rails new rails6_template --database=postgresql`

Add these gems:

```ruby
# Gemfile.rb
gem 'devise'
gem 'rails_admin'
```

Set up databases:

```ruby
bundle install
rails db:migrate
rails db:setup
rails s
```

If you're greeted with 'Yay' then basic smokecheck is done - rails is installed.

__Configure UUID__

Generate a migration to capture the Postgres change to generate full uuids instead of simple ones:

`rails g migration EnableUUID`

migration file:
```ruby
class EnableUuid < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'pgcrypto'
  end
end
```

Set UUID as default behavior:

```ruby
# config/initializers/generators.rb:
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end
```

Test that UUID is working with a dummy resource:

```ruby
rails g scaffold post title:string body:text published:boolean
rails db:migrate
rails s
```

Then at localhost:3000/posts create a few posts and see that on show, they are full UUID's instead of /post/1


__Add an appname and helper__

```ruby
config/application.rb
-----------------------
# Application Name Definition - called with Rails.application.appname or via Pages Helper Method
def appname
  @appname = "Rails Template Application Name"
end
```

```ruby
# helpers/pages_helper.rb
# Pull the application name set in config/application.rb
# Call with appname in page layouts like <%= appname %>
def appname
  @appname = Rails.application.appname
end
```

Restart the server - add <%= appname %> to app/views/pages/index.html.erb and reload to see if the appname helper is working.

__Generate App Pages__

Generate app pages that we'll filter, show, redirect to once we have authentication set up.

`rails g controller pages index welcome about`

Then so that they display from root instead of pages/<pagename> edit routes.rb:

```ruby
# match on /page instead of the technically correct /pages/page
# get 'pages/welcome'
# get 'pages/about'
match '/about', to: 'pages#about', via: 'get'
match '/welcome', to: 'pages#welcome', via: 'get'
# for the temporary resource
resources :posts
# fall through to root
root 'pages#index'
```

__Improve page layout and dynamic title and description meta tags__

Application Layout at app/views/layouts/application.html.erb:

```ruby
    <title><% if content_for?(:page_title) %><%= appname %> | <%= yield(:page_title) %><% else %><%= appname %><% end %></title>
    <% if content_for?(:page_description) %><meta name="description" content="<%= yield(:page_description) %>"/><% end %>
```

Then in individual pages add title and descriptions like:

```ruby
<%= content_for :page_title, 'Home Page' %>
<%= content_for :page_description, 'Home Page' %>
```

__Prepare your user resource__

Before installing Devise, which will hook into user - we'll first add some fields for first and last name, and a simple boolean to check if the user is an admin or not that will be useful when adding an admin backend to the app later.

`rails g model user firstname:string lastname:string isadmin:boolean`

Note the re-ordered migration to remove the created_at and updated_at columns on user so that the devise install migration works.

__Install devise__

`rails g devise:install`

Adjust config/environments/development.rb for devise and mailcatcher:

```ruby
# devise install wants a default url
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
config.action_mailer.delivery_method = :smtp
# mailcatcher gem
config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }
```

Add alerts in our main layout in views/layouts/application.html.erb:

```html
<p class="notice"><%= notice %></p>
<p class="alert"><%= alert %></p>
```

And now install devise for our user resource:

`rails g devise User`

Now time to configure our user model with the devise modules we want:

```ruby
#app/models/user.rb:
devise :database_authenticatable, :registerable, :confirmable,
       :recoverable, :validatable, :timeoutable, :trackable

       class DeviseCreateUsers < ActiveRecord::Migration[6.1]
         def change
           create_table :users, id: :uuid do |t|
             ## Database authenticatable
             t.string :email,              null: false, default: ""
             t.string :encrypted_password, null: false, default: ""

             ## Recoverable
             t.string   :reset_password_token
             t.datetime :reset_password_sent_at

             ## Rememberable
             t.datetime :remember_created_at

             ## Trackable
             t.integer  :sign_in_count, default: 0, null: false
             t.datetime :current_sign_in_at
             t.datetime :last_sign_in_at
             t.string   :current_sign_in_ip
             t.string   :last_sign_in_ip

             ## Confirmable
             t.string   :confirmation_token
             t.datetime :confirmed_at
             t.datetime :confirmation_sent_at
             t.string   :unconfirmed_email # Only if using reconfirmable

             ## Lockable
             t.integer  :failed_attempts, default: 3, null: false # Only if lock strategy is :failed_attempts
             t.string   :unlock_token # Only if unlock strategy is :email or :both
             t.datetime :locked_at

             t.timestamps null: false
           end

           add_index :users, :email,                unique: true
           add_index :users, :reset_password_token, unique: true
           add_index :users, :confirmation_token,   unique: true
           add_index :users, :unlock_token,         unique: true
         end
       end
```

Test it all:

```ruby
rails db:migrate
rails s
mailcatcher
localhost:1080
localhost:3000/users/sign_up
```

Now configure cleaner auth routes like /signup /signout instead of user/signup:

```ruby
#routes.rb
# change default /user/action URLs for devise
devise_for :users, path: '', path_names: { sign_in: 'signin', sign_out: 'signout', password: 'iforgot', confirmation: 'verification', unlock: 'unlock', registration: '', sign_up: 'signup' }
```

Add your custom fields to the signup and edit forms:

`rails g devise:views`

```html
# views/devise/registrations/edit and new
<div class="field">
  <%= f.label "First Name" %><br />
  <%= f.text_field :firstname, autofocus: true, autocomplete: "first name" %>
</div>

<div class="field">
  <%= f.label "Last Name" %><br/>
  <%= f.text_field :lastname, autocomplete: "first name" %>
</div>
```

Adjust permitted parameters in application_controller.rb, and change post-signin and signout redirects (only a signed in user should see the welcome page):

```ruby
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # override the devise signin and signout url behavior
  def after_sign_in_path_for(_resource_or_scope)
    welcome_url
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_url
  end

  protected

  # Allow extra attributes for user signup and user profile edit
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:firstname, :lastname, :email, :password, :current_password, :isadmin)
    end

    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:firstname, :lastname, :email, :password, :password_confirmation,
               :current_password, :isadmin)
    end
  end
end
```

__Generate a Rails Admin backend__
```ruby
rails g rails_admin:install
```
Add an admin flag to one of your users:
```ruby
rails c
User.all
u = User.second
u.isdamin = 'true'
u.save
```

When a user with admin privs logs in, a new __admin__ link appears in the navbar and allows access to the admin backend.

__Install and configure TailwindCSS 2__

```bash
rails db:environment:set RAILS_ENV=development
npm update
bundle update
bundle install
yarn add tailwindcss@npm:@tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9\n
npx tailwindcss init
./node_modules/.bin/tailwind build ./app/javascript/stylesheets/application.scss -o
mkdir ./app/javascript/stylesheets
mv ./tailwind.config.js ./app/javascript/stylesheets
rm package-lock.json
yarn update
yarn
```
