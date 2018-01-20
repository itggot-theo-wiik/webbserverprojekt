class Main < Sinatra::Base

    enable :sessions

    get '/' do
        slim :shop
    end

    get '/log-in' do
        slim :'log-in'
    end

    post '/log-in' do
        email = params['inputEmail']
        password = params['inputPassword']

        if User.authenticate(email, password, session)
            redirect '/'
        else
            redirect '/log-in'
        end
    end
end