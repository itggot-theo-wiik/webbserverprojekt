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

    get '/register' do
        slim :register
    end

    post '/register' do
        username = params['inputUsername']
        email = params['inputEmail']
        password = params['inputPassword']

        if User.create(username, email, password, session)
            redirect '/'
        else
            redirect '/register'
        end
    end

    get '/log-out' do
        session.destroy
        redirect '/log-in'
    end

end