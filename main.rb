class Main < Sinatra::Base

    enable :sessions

    get '/' do
        session[:return_url] = "/"
        @random_merch = Merch.get_random()
        @comments = Comment.all('reverse')

        slim :home
    end

    post '/' do
        comment = params[:inputComment]
        img_url = params[:inputImgUrl]

        redirect '/' unless session[:id]

        date = Time.now.to_s
        if Comment.create({user_id: session[:id].to_i, comment: comment, img_url: img_url})
            redirect '/'
        else
            redirect '/error'
        end

    end

    get '/shop' do
        session[:return_url] = "/shop"
        @merch_type = params['merch_type']
        @size = params['size']

        @merchandises = Merch.all(@merch_type, @size)
        @merch_types = Merch.get_types()
        @sizes = Merch.get_sizes()

        slim :shop
    end

    post '/shop' do
        merch_types = params[:merch_types]
        sizes = params[:sizes]

        redirect_url = '/shop'
        if merch_types || sizes
            redirect_url += '?'

            if merch_types
                merch_types.each_with_index do |x, i|
                    redirect_url += "merch_type[]=#{merch_types[i].to_s}&"
                end
            end

            if sizes
                sizes.each_with_index do |x, i|
                    redirect_url += "size[]=#{sizes[i].to_s}&"
                end
            end

        end

        redirect "#{redirect_url}"
    end

    get '/log-in' do
        slim :'log-in'
    end

    post '/log-in' do
        email = params['inputEmail']
        password = params['inputPassword']

        if User.authenticate(email, password, session)
            if session[:return_url]
                url = session[:return_url]
                session[:return_url] = false
                redirect "#{url}"
            else
                redirect '/shop'
            end
        else
            redirect '/log-in'
        end
    end

    get '/register' do
        # redirect '/shop'
        slim :register
    end

    post '/register' do
        username = params['inputUsername']
        email = params['inputEmail']
        password = params['inputPassword']
        secret = params['inputSecret']

        if secret != "spam2"
            redirect '/register'
        end

        if User.create(username, email, password, session)
            redirect '/shop'
        else
            redirect '/register'
        end
    end

    get '/log-out' do
        session.destroy
        redirect '/log-in'
    end

    get '/my-profile' do
        redirect '/log-in' unless session[:id]
    end

    post '/my-profile' do
        user_id = params[:inputUserId]
        new_password = params[:inputPassword]

        p session[:id].to_i
        p user_id.to_i
        p new_password

        # Is the forms password the same as the logged in one?
        if (session[:id].to_i == user_id.to_i) && new_password != nil
            User.change_password(user_id.to_i, new_password)
            session[:password_change_successfull] = true
        else
            session[:password_change_successfull] = false
        end

        redirect '/my-profile'

    end

    get '/items' do
        redirect '/shop'
    end

    get '/items/:id' do
        id = params[:id].to_i
        session[:return_url] = "/items/#{id}"
        @merch = Merch.one(id)
        @items = Item.one(id)

        @items = @items.sort_by{|x| x.size_id}

        slim :show
    end

    get '/about' do
        slim :about
    end

    get '/cart' do
        if session[:id]
            @cart = Cart.get(session[:cart], session[:id])
        redirect '/log-in' unless session[:id]

            @items = []
        @cart = Cart.get(session[:cart], session[:id])

        ids = []
        @cart.map { |x| ids << x.first }
        @items = Item.one_from_id(ids)

        if @items.length < @cart.length
            (@cart.length - @items.length).times do |x|
                @items << nil
            end
        end

        slim :cart
    end

    post '/cart' do
        if session[:id]
            item = params['item']

            if item == nil
                redirect '/shop'
                p "item was now nill, this was not good :("
            end

            if Cart.add(item, session)
                redirect '/cart'
            else
                redirect '/shop'
            end

        else
            redirect '/log-in'
        end
    end

    post '/remove_from_cart_cheat_fix' do
        cart_id = params['cart_id']
        session[:cart].delete_at(cart_id.to_i)
        redirect '/cart'
    end

    get '/orders' do
        redirect '/log-in' unless session[:id]
    end

    post '/orders' do
        redirect '/log-in' unless session[:id]
            end

            @cart = Cart.get(session[:cart], session)

            @items = []
            @cart.each do |x|
                @items << Item.one_from_id(x.first)
            end

            Order.create(@items, session)

            redirect '/orders'
        else
            redirect '/log-in'
        end
    end

    post '/order_confirmation' do

    end

    get '/orders/:id' do

    end

    # Admin
    get '/admin' do
        if session[:admin]
            slim :'admin/admin'
        else
            redirect '/log-in'
        end
    end

     get '/admin/items' do
        if session[:admin]
            @brands = Brand.all()
            @colors = Color.all()
            db = SQLite3::Database.open('db/db.sqlite')
            @merchandise = db.execute('SELECT * FROM merch')
            @sizes = Size.all()
            slim :'admin/items'
        else
            redirect '/log-in'
        end
    end

    post '/admin/items' do
        merch = params[:inputMerch]
        color = params[:inputColor]
        size = params[:inputSize]
        amount = params[:inputAmount]

        if amount == ""
            amount = 1
        end

        if !merch || !color || !size || !amount || amount.to_i == 0
            session[:add_item_error] = "Please. Don't be a dummy! 🤓💲"
        end

        Item.add(merch: merch, color: color, size: size, amount: amount.to_i)

        redirect '/admin/items'
    end

    get '/admin/users' do
        @users = User.all()
        slim :'admin/users'
    end

    get '/admin/brands' do
        if session[:admin]
            slim :'admin/brands'
        else
            redirect '/log-in'
        end
    end

    get '/admin/orders' do
        # if session[:admin]
            @packaging = params['packaging']
            @shipping = params['shipping']
            @recieved = params['recieved']
            @returned = params['returned']

            if @packaging != "packaging" && @shipping != "shipping" && @recieved != "recieved" && @returned != "returned"
                @orders = Order.all_active()
            else
                @orders = Order.get_with_filter(@packaging, @shipping, @recieved, @returned)
            end

            slim :'admin/orders'
        # else
            # redirect '/log-in'
        # end
    end

    post '/admin/orders' do
        puts "Filter: #{params[:inputStatus]}"
        puts "User id: #{params[:inputUserId]}"

        filter = params[:inputStatus]

        url = "/admin/orders"

        things = ['packaging', 'shipping', 'recieved', 'returned']

        if filter
            url = url + "?"
            things.each_with_index do |x, i|
                if filter.include? (x)
                    url += "#{x}=#{x}&"
                end
            end
        else
            p "no filter!!!!"
        end

        redirect "#{url}"
    end

    post '/admin/change_status' do
        @status = params[:inputStatus]
        @user_id = params[:inputUserId]
        @order_id = params[:inputOrderId]

        Order.change_status(@order_id.to_i, @user_id.to_i, @status)
        redirect '/admin/orders'
    end

    get '/admin/add_random' do
        if session[:admin]
            db = SQLite3::Database.open('db/db.sqlite')
            100.times do
                color = rand(4) + 1
                merch = rand(12) + 1
                size = rand(4) + 1
                status = "ready_for_shipping"
                db.execute('INSERT INTO items (status, size_id, color_id, merch_id) VALUES (?,?,?,?)', [status, size, color, merch])
            end
            redirect '/shop'
        else
            redirect '/log-in'
        end
    end

    get '/stats' do
        @total_money_spent = Statistic.total_money()
        @percentage_of_orders_recieved = Statistic.percentage_of_orders_recieved()
        slim :stats
    end

    get '/gamble' do
        session[:return_url] = "/gamble"
        if session[:id]
            @balance = Gamble.balance(11)
        end
        slim :gamble
    end

    get '/coin-flip' do
        redirect '/gamble'
    end

    post '/coin-flip' do

        redirect '/log-in' unless session[:id]
            else
                # Can not
            end
        else
            redirect '/log-in'
        end
    end

end