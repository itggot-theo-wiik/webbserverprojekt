class Item

    attr_reader :merch_id, :name, :price, :color_name, :color_hex, :size

    def initialize(merch_id, item = nil)
        db = SQLite3::Database.open('db/db.sqlite')
        merch = db.execute('SELECT * FROM merch WHERE id IS ?', merch_id).first
        @merch_id = merch_id
        @name = merch[1]
        @price = merch[2]

        # More specific variables
        if item != nil
            @color_name = db.execute('SELECT name FROM colors WHERE id IS ?', item[3]).first.first
            @color_hex = db.execute('SELECT hex FROM colors WHERE id IS ?', item[3]).first.first
            @size = db.execute('SELECT size FROM sizes WHERE id IS ?', item[2]).first.first
        end
    end

    def self.get()
        db = SQLite3::Database.open('db/db.sqlite')
        merch_ids = db.execute('SELECT merch_id FROM items WHERE status IS ?', "ready_for_shipping").uniq

        output = []
        merch_ids.each do |merch_id|
            output << Item.new(merch_id.first)
        end

        return output
    end

    def self.get_merch(merch_id)
        db = SQLite3::Database.open('db/db.sqlite')
        items = db.execute('SELECT * FROM items WHERE status IS ? AND merch_id IS ?', ["ready_for_shipping", merch_id]).uniq.sort

        output = []
        items.each do |item|
            output << Item.new(merch_id, item)
        end

        return output
    end

end