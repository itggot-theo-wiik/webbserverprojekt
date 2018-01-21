require 'bundler'
Bundler.require

use Rack::MethodOverride

require_relative 'main.rb'

require_relative 'models/item.rb'
require_relative 'models/user'

Slim::Engine.set_options pretty: true, sort_attrs: false

run Main