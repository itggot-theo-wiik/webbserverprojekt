#Empty line to create pull request
require 'bundler'
Bundler.require

use Rack::MethodOverride

require_relative 'main.rb'

require_relative 'models/baseclass.rb'
require_relative 'models/merch.rb'
require_relative 'models/user.rb'
require_relative 'models/order.rb'
require_relative 'models/cart.rb'
require_relative 'models/item.rb'
require_relative 'models/gamble.rb'
require_relative 'models/statistic.rb'
require_relative 'models/brand.rb'
require_relative 'models/color.rb'
require_relative 'models/size.rb'
require_relative 'models/comment.rb'

Slim::Engine.set_options pretty: true, sort_attrs: false

run Main