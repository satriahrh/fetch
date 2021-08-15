FROM ruby:3.0.2

WORKDIR /app-data
COPY . /app-data/
RUN bundle install

ENTRYPOINT [ "bundle", "exec", "ruby", "main.rb" ]
