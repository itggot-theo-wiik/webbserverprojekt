require 'bundler'
Bundler.require

use Rack::MethodOverride

require_relative 'main.rb'

files = Dir.glob("models/*.rb")
files.map { |x| require_relative "#{x}" }

Slim::Engine.set_options pretty: true, sort_attrs: false

run Main