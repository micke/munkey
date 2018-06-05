# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.1"

gem "rails", "~> 5.2.0"

gem "dotenv-rails", "~> 2.4", groups: %i[development test]

gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 3.11"

gem "coffee-rails", "~> 4.2"
gem "jquery-rails", "~> 4.3.3"
gem "uglifier", ">= 1.3.0"

gem "turbolinks", "~> 5"

gem "bootstrap", "~> 4.1"
gem "font-awesome-rails", "~> 4.7"
gem "haml", "~> 5.0"
gem "sass-rails", "~> 5.0"

gem "concurrent-ruby", "~> 1.0"

gem "sentry-raven", "~> 2.7"

gem "rubocop", "~> 0.56", require: false

gem "discordrb", github: "lisinge/discordrb", branch: "fix_server_role_delete_event"

gem "google-cloud-vision", require: "google/cloud/vision"
gem "parslet"
gem "simple-rss"

gem "bootsnap", ">= 1.1.0", require: false

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "pry"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 2.15", "< 4.0"
  gem "chromedriver-helper"
  gem "selenium-webdriver"
end

gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
