class Main < Sinatra::Base

    enable :sessions

    get '/' do
        slim :shop
    end

    get '/log-in' do
        slim :'log-in'
    end

end