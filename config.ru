require 'bundler'
Bundler.require

use Rack::MethodOverride

require_relative 'main.rb'

position = Dir.getwd
files = Dir.entries("#{position}/models")[2..-1]

files.map { |x| require_relative "models/#{x}" }

Slim::Engine.set_options pretty: true, sort_attrs: false

run Main