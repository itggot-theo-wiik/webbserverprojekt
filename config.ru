require 'bundler'
Bundler.require

use Rack::MethodOverride

require_relative 'main.rb'

Slim::Engine.set_options pretty: true, sort_attrs: false

run Main