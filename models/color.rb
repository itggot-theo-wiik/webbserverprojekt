#Empty line to create pull request
class Color < MyBaseclass

    attr_reader :id, :name, :hex
    table_name('colors')

    def initialize(color)
        @id = color.first
        @name = color[1]
        @hex = color[2]
    end

    # def self.all()
    #     db = SQLite3::Database.open('db/db.sqlite')
    #     colors = db.execute('SELECT * FROM colors')

    #     output = []
    #     colors.each do |color|
    #         output << Color.new(color)
    #     end

    #     return output
    # end

end