#Empty line to create pull request
class Brand < MyBaseclass

    attr_reader :id, :name
    table_name('brands')

    def initialize(brand)
        @id = brand.first
        @name = brand[1]
    end

    # def self.all()
    #     db = SQLite3::Database.open('db/db.sqlite')
    #     brands = db.execute('SELECT * FROM brands')

    #     output = []
    #     brands.each do |brand|
    #         output << Brand.new(brand)
    #     end

    #     return output
    # end

end