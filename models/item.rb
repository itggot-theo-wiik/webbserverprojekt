class Item
    attr_reader :status, :id, :price, :size_id, :size_name, :color_id, :color_name, :color_hex, :merch_id, :merch_type, :name, :sale, :merch_type_id, :size, :hex

    def initialize(item)
        @id = item.first
        @status = item[1]
        @name = item[2]

        @price = item[3]
        @sale = 0

        @size_id = item[4]
        @size_name = item[5]

        @color_id = item[6]
        @color_name = item[7]
        @color_hex = item[8]

        @merch_id = item[9]
        @merch_type_id = item[10]
        @merch_type = item[11]

    end

    def self.one(merch_id)
        db = SQLite3::Database.open('db/db.sqlite')
        output = []

        items = db.execute("SELECT items.id, status, merch.name, price, size_id, sizes.size, colors.id as 'color_id', colors.name as 'color_name', hex, merch_id, merch_type_id, merch_type.name FROM items
        INNER JOIN merch
        ON items.merch_id = merch.id
        INNER JOIN colors
        ON items.color_id = colors.id
        INNER JOIN sizes
        ON items.size_id = sizes.id
        INNER JOIN merch_type
        ON merch.merch_type_id = merch_type.id
        WHERE status IS 'ready_for_shipping' AND merch_id IS ?", merch_id.to_i)

        items.each do |item|
            output << Item.new(item)
        end

        return output
    end

    def self.one_from_id(id)
        db = SQLite3::Database.open('db/db.sqlite')

        item = db.execute("SELECT items.id, status, merch.name, price, size_id, sizes.size, colors.id as 'color_id', colors.name as 'color_name', hex, merch_id, merch_type_id, merch_type.name FROM items
        INNER JOIN merch
        ON items.merch_id = merch.id
        INNER JOIN colors
        ON items.color_id = colors.id
        INNER JOIN sizes
        ON items.size_id = sizes.id
        INNER JOIN merch_type
        ON merch.merch_type_id = merch_type.id
        WHERE status IS 'ready_for_shipping' AND items.id IS ?", id).first

        return Item.new(item)
    end

    def self.add(merch:, color:, size:, amount:)

        db = SQLite3::Database.open('db/db.sqlite')
        
        amount.times do
            db.execute('INSERT INTO items (status, size_id, color_id, merch_id) VALUES (?,?,?,?)', ["ready_for_shipping", size, color, merch])
        end

    end
end