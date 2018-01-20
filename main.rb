class Main < Sinatra::Base

    enable :sessions

    get '/' do
        slim :shop
    end

end