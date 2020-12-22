devlog
======

rails new rails6_template --database=postgresql

Gemfile:
gem 'devise'

rails db:migrate
rails db:setup

rails s
rails g migration EnableUUID

migration file:
class EnableUuid < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'pgcrypto'
  end
end

config/initializers/generators.rb:
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end

rails g scaffold post title:string body:text published:boolean
rails db:migrate
rails s
localhost:3000/posts
confirm created posts use UUID instead of ID

rails g controller pages index welcome about

routes.rb:
# match on /page instead of the technically correct /pages/page
# get 'pages/welcome'
# get 'pages/about'
match '/about', to: 'pages#about', via: 'get'
match '/welcome', to: 'pages#welcome', via: 'get'
# for the temporary resource
resources :posts
# fall through to root
root 'pages#index'

Gemfile:
gem 'devise'



rails g model user firstname:string lastname:string isadmin:boolean





bundle install
rails g devise:install

config/environments/development.rb:
# devise install wants a default url
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
config.action_mailer.delivery_method = :smtp
# mailcatcher gem
config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }

views/layouts/application.html.erb:
<p class="notice"><%= notice %></p>
<p class="alert"><%= alert %></p>

rails g devise User

app/models/user.rb:
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

rails db:migrate
mailcatcher
localhost:1080
localhost:3000/users/sign_up

rails g devise:views


TODO:
- redirect
- add firstname lastname with security to user form and signup form
