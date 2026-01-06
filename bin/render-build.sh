#!/usr/bin/env bash

set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean

bin/rails db:migrate

# bundle install; bundle exec rake assets:precompile; bundle exec rake assets:clean;
# bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}