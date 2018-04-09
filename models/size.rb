class Size

    attr_reader :id, :name

    def initialize(size)
        @id = size.first
        @name = size[1]
    end

    def self.all()
        db = SQLite3::Database.open('db/db.sqlite')
        sizes = db.execute('SELECT * FROM sizes')
        output = []

        sizes.map { |size| output << Size.new(size) }
        
        # sizes.each do |size|
        #     output << Size.new(size)
        # end

        return output
    end
end