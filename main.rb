class Main < Sinatra::Base

    enable :sessions

    get '/' do
        @items = Item.get()
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

    get '/my-profile' do
        if session[:id]
            @user = User.get(session[:id].to_i)
            slim :'my-profile'
        else
            redirect '/log'
        end
    end

    get '/items' do
        redirect '/'
    end

    get '/items/:id' do
        id = params[:id].to_i
        @items = Item.get_merch(id)
        slim :show
    end

end