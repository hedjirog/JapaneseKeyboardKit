#!/bin/sh
set -e

export LC_ALL="en_US.UTF-8"

which bundle >/dev/null 2>&1 || gem install bundler
bundle install
bundle exec pod install
