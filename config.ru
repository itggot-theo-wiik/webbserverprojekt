require 'bundler'
Bundler.require
require_relative 'main.rb'
Slim::Engine.set_options pretty: true, sort_attrs: false
run Main