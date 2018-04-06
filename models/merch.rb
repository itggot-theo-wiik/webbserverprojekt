#Empty line to create pull request
class Merch

    attr_reader :merch_id, :name, :price, :color_name, :color_hex, :size, :brands, :id, :img_url

    def initialize(merch)
        db = SQLite3::Database.open('db/db.sqlite')

        @id = merch[0]
        @name = merch[1]
        @price = merch[2]
        @merch_type_id = merch[3]
        @sale = merch[4]
        @img_url = merch[5]

        @brands = []
        db.execute('SELECT name FROM brands WHERE id IN (SELECT brand_id FROM merch_brand WHERE merch_id IS ?)', @id).each do |x|
            @brands << x.first
        end

        # @brands = Brand.new()
    end

    # With query
    def self.all(merch_types, sizes)
        db = SQLite3::Database.open('db/db.sqlite')

        if merch_types || sizes
            # merchandises = []

             if merch_types
                matching_merch_types = []
                # Add the matching merch types to the merch array
                merch_types.length.times do |i|
                    matching_merch_types += db.execute('SELECT * FROM merch WHERE merch_type_id IS ?', merch_types[i].to_i)
                end
            end
 
            if sizes
                matching_sizes = []
                # Add the merch which has items that is in the wanted sizes
                sizes.length.times do |i|
                    matching_sizes += db.execute('SELECT * FROM merch WHERE id IN (SELECT merch_id FROM items WHERE status IS "ready_for_shipping" AND size_id IN (?))', sizes[i])
                end
                matching_sizes = matching_sizes.uniq
            end

            # Filter with sizes and merch types?
            if matching_merch_types != nil && matching_sizes != nil
                merchandises = (matching_merch_types & matching_sizes)
            else
                # Only merch types? Then size does not matter
                if matching_merch_types != nil
                    merchandises = matching_merch_types
                else
                    merchandises = matching_sizes
                end
            end
        else
            merchandises = db.execute('SELECT * FROM merch')
        end

        output = []
        merchandises.each { |x| output << Merch.new(x) }
        return output    
    end

    def self.one(merch_id)
        db = SQLite3::Database.open('db/db.sqlite')
        item = db.execute('SELECT * FROM merch WHERE id IS ?', merch_id.to_i).first
        return Merch.new(item)
    end

    def self.get_types()
        db = SQLite3::Database.open('db/db.sqlite')
        return db.execute('SELECT * FROM merch_type')
    end

    def self.get_sizes()
        db = SQLite3::Database.open('db/db.sqlite')
        return db.execute('SELECT * FROM sizes')
    end

    def self.get_random()
        db = SQLite3::Database.open('db/db.sqlite')
        return Merch.new(db.execute('SELECT * FROM merch').sample)
    end

end