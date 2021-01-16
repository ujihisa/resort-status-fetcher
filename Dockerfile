FROM ruby:3.0.0

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY app.rb ./
ENV PORT=8080
EXPOSE ${PORT}

CMD ["bundle", "exec", "ruby", "./app.rb"]
