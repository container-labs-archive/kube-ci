FROM ruby:alpine

RUN mkdir /app
WORKDIR /app

COPY ./Gemfile /app/Gemfile
RUN bundle install

COPY ./ /app

ENTRYPOINT ["bundle", "exec", "ruby", "run.rb"]
