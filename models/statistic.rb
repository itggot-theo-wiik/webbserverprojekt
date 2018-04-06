#Empty line to create pull request
class Statistic

    def self.total_money()
        db = SQLite3::Database.open('db/db.sqlite')
        return db.execute('SELECT sum(price) FROM order_item').first.first.to_i
    end

    def self.percentage_of_orders_recieved()
        db = SQLite3::Database.open('db/db.sqlite')
        shipping = db.execute('SELECT count(*) FROM orders WHERE status is ?', "shipping").first.first.to_f
        recieved = db.execute('SELECT count(*) FROM orders WHERE status is ?', "recieved").first.first.to_f

        return ((recieved / (shipping + recieved)) * 100).to_i
    end

end