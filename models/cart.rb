#Empty line to create pull request
class Cart

    def initialize
    end

    def self.get(cart, user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        items = []

        if cart
            cart.each do |x|
                # items << Item.new(db.execute('SELECT * FROM items WHERE merch_id IS ? AND color_id IS ? AND size_id IS ?', [x.first, x[1], x[2]]).first)
                item = db.execute('SELECT * FROM items WHERE merch_id IS ? AND color_id IS ? AND size_id IS ? AND status IS ?', [x.first, x[1], x[2], "ready_for_shipping"])
                
                if item != []
                    items << item.first
                else
                    items << false
                end

            end
        end

        return items
    end

    def self.add(item_id, session)
        db = SQLite3::Database.open('db/db.sqlite')

        items = db.execute('SELECT merch_id, color_id, size_id FROM items WHERE id IS ? AND status IS ?', [item_id, "ready_for_shipping"])

        if items != nil
            unless session[:cart]
                session[:cart] = []
            end

            session[:cart] << items.first

            return true
        else
            return false
        end
    end

end