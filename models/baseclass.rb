class MyBaseclass

    def self.table_name(name)
        @table_name = name
    end

    def self.column(name, options = nil)
        @columns ||= []

        if !options
            @columns << name
        else
            @columns << {name => , options}
        end

    end

    def self.columns
        @columns
    end

    def self.get(id)
        db = SQLite3::Database.open('db/db.sqlite')
        result = db.execute("SELECT * FROM #{@table_name} WHERE id IS ?", id).first
        return self.new(result)
    end

    def self.all()
    def self.all(sort = nil)
        db = SQLite3::Database.open('db/db.sqlite')
        all = db.execute("SELECT * FROM #{@table_name}")

        output = []
        case sort
            when 'reverse'
                all = db.execute("SELECT * FROM #{@table_name} ORDER BY id DESC")
            else
                all = db.execute("SELECT * FROM #{@table_name}")
        end

        output = []
        all.map { |one| output << self.new(one) }
        
        # all.each do |one|
        #     output << self.new(one)
        # end

        return output
    end

    #Comment.create(comment: "hej", img_url: "slkdjfldkjf")
    def self.create(hash)
        keys = hash.keys.map { |key| key.to_s}
        values = hash.values.map { |value| value.to_s}
        db = SQLite3::Database.open('db/db.sqlite')

        arr = '?' * @columns.length
        
        # @columns.length.times do |x|
        #     arr << '?'
        # end

        db.execute("INSERT INTO #{@table_name} (#{@columns.join(', ')}) VALUES (#{arr.join(', ')})", values)

    end
end