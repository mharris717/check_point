source "http://rubygems.org"

#### SPECIAL GEMFILE BLOCK START
def private_gem(name)
  gem name, '0.3.0', git: "https://#{ENV['GITHUB_TOKEN']}:x-oauth-basic@github.com/mharris717/#{name}.git", branch: :master
end
#### SPECIAL GEMFILE BLOCK END

group :development do
  gem "rspec", "~> 2.8.0"
  gem "rdoc", "~> 3.12"
  gem "bundler", ">= 1.0"
  gem "jeweler", "~> 1.8.7"
  #gem "rcov", ">= 0"

  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spork'

  gem 'rb-fsevent', '~> 0.9'
end

gem 'mharris_ext'
gem 'andand'

# private_gem 'mongoid_gem_config'

# gem 'mongoid', github: "mongoid/mongoid"

gem 'git'