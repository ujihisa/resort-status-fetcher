FROM ruby:3.0.0

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY app.rb ./
COPY lib ./lib
EXPOSE 8080

CMD ["bundle", "exec", "ruby", "./app.rb"]
