FROM ruby:2.5.1
MAINTAINER Micke Lisinge <me@mike.gg>

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile* ./
RUN bundle install

COPY . ./

CMD ["ruby", "discordbot.rb"]
CMD ["rails", "server", "-b", "0.0.0.0", "-e", "production"]
