#Empty line to create pull request
class Order < MyBaseclass

    attr_reader :id, :status, :order_date, :items, :user_id
    table_name('orders')

    def initialize(order)
        db = SQLite3::Database.open('db/db.sqlite')

        @id = order.first
        @status = order[1]
        @order_date = order[2]
        @user_id = order[3]

        @items = []

        items = db.execute('SELECT size_name, price, merch_type_name, color_hex, color_name, merch_name, sale FROM order_item WHERE order_id IS ?', order.first.to_i)

        items.each do |item|
            @items << item
        end        
    end

    # Make a new order
    def self.create(items, session)
        db = SQLite3::Database.open('db/db.sqlite')

        # Check if all the items are in stock
        # if db.execute('SELECT * FROM items WHERE status IS ? AND ', ["ready_for_shipping", x])

        # Set the order ID
        date = Time.now.to_s

        db.execute('INSERT INTO orders (status, order_date, user_id) VALUES (?,?,?)', ["packaging", date, session[:id].to_i])
        order_id = db.execute('SELECT id FROM orders WHERE order_date IS ? AND user_id IS ?', [date, session[:id].to_i]).first.first

        items.each_with_index do |item, i|
            # Add the items

            # One line NEW
            db.execute('INSERT INTO order_item (order_id, item_id, color_id, color_hex, color_name, size_id, size_name, price, sale, merch_type_name, merch_type_id, merch_name, merch_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)', [order_id, item.id, item.color_id, item.color_hex, item.color_name, item.size_id , item.size_name, item.price, item.sale, item.merch_type, item.merch_type_id, item.name, item.merch_id])

            # Set item to "bought"
            db.execute('UPDATE items SET status = ? WHERE id IS ?', ["bought", item.id.to_i])

        end

        session[:cart] = []

    end


    #Order.get(id: 3)
    #Order.all(user_id: 5)
    def self.get(user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        output = []

        orders = db.execute('SELECT * FROM orders WHERE user_id IS ?', user_id)

        orders.each do |order|
            # p order
            output << Order.new(order)
        end

        return output
    end

    def self.all_active()
        db = SQLite3::Database.open('db/db.sqlite')
        output = []

        orders = db.execute('SELECT * FROM orders')

        orders.each do |order|
            output << Order.new(order)
        end

        return output
    end

    def self.get_with_filter(packaging, shipping, recieved, returned)
        db = SQLite3::Database.open('db/db.sqlite')

        orders = db.execute('SELECT * FROM orders WHERE status IN (?,?,?,?)', [packaging, shipping, recieved, returned])

        output = []
        orders.each do |order|
            output << Order.new(order)
        end

        return output
    end

    def self.change_status(order_id, user_id, status)
        db = SQLite3::Database.open('db/db.sqlite')

        if db.execute('SELECT * FROM orders WHERE id IS ? AND user_id IS ?', [order_id, user_id]) != []
            # Correct
            db.execute('UPDATE orders SET status = ? WHERE id IS ?', [status, order_id])
            return true
        else
            # Not correct
            return false
        end
    end
end