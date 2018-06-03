FROM ruby:2.5
MAINTAINER Micke Lisinge <me@mike.gg>

WORKDIR /app
COPY Gemfile* ./
RUN bundle install

COPY . ./

CMD ["ruby", "discordbot.rb"]

