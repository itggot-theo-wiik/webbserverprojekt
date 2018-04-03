class Item
    attr_reader :status, :id, :price, :size_id, :size_name, :color_id, :color_name, :color_hex, :merch_id, :merch_type, :name, :sale, :merch_type_id

    def initialize(item)
        db = SQLite3::Database.open('db/db.sqlite')

        # colors_db = db.execute('SELECT * FROM colors WHERE id IS ?', item[3])
        # merch_db = db.execute('SELECT * FROM merch WHERE id IS ?', item[4])
        # sizes_db = db.execute('SELECT * FROM sizes WHERE id IS ?', item[2])

        # Main
        @id = item.first
        @status = item[1]

        # Price
        @price = db.execute('SELECT price FROM merch WHERE id IS (SELECT merch_id FROM items WHERE id IS ?)', @id).first.first
        @sale = 0

        # Size
        @size_id = item[2]
        @size_name = db.execute('SELECT size FROM sizes WHERE id IS ?', item[2]).first.first

        # Color id
        @color_id = item[3]
        @color_name = db.execute('SELECT name FROM colors WHERE id IS ?', item[3]).first.first
        @color_hex = db.execute('SELECT hex FROM colors WHERE id IS ?', item[3]).first.first

        # Merch stuff, name etc
        @merch_id = item[4]
        @name = db.execute('SELECT name FROM merch WHERE id IS ?', @merch_id).first.first
        @merch_type = db.execute('SELECT name FROM merch_type WHERE id IS (SELECT merch_type_id FROM merch WHERE id IS ?)', @merch_id).first.first
        @merch_type_id = db.execute('SELECT id FROM merch_type WHERE name IS ?', @merch_type).first.first
    end

    def self.one(merch_id)
        db = SQLite3::Database.open('db/db.sqlite')
        output = []

        db.execute('SELECT * FROM items WHERE merch_id IS ? AND status = ?', [merch_id.to_i, "ready_for_shipping"]).each do |x|
            output << Item.new(x)
        end

        return output
    end

    def self.add(merch:, color:, size:, amount:)

        db = SQLite3::Database.open('db/db.sqlite')
        
        amount.times do
            db.execute('INSERT INTO items (status, size_id, color_id, merch_id) VALUES (?,?,?,?)', ["ready_for_shipping", size, color, merch])
        end

    end
end