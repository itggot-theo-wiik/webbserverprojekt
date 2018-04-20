class MyBaseclass

    def self.table_name(name)
        @table_name = name
    end

    def self.column(name, options = nil)
        @columns ||= {}
        @columns[name] = options
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
        db = SQLite3::Database.open('db/db.sqlite')

        arr_of_question_marks = ('?' * @columns.length).split(//).join(', ')

        default = []

        # Loop trough all the columns and check if
        # there are any options :~)
        @columns.each do |column|
            if column[1] != nil

                # BCrypt Password
                if column[1][:type] == "BCryptHash"
                    hash[column[0].to_sym] = BCrypt::Password.create(hash[column[0].to_sym])
                end

                # Unique
                if column[1][:unique]
                    query = db.execute("SELECT * FROM #{@table_name} WHERE #{column[0]} IS ?", hash[column[0].to_sym])
                    if query != []
                        return false
                    end
                end

                # Required
                if column[1][:required]
                    hash.each_with_index do |thang, i|

                        # Empty?
                        if "#{thang[0]}" == "#{column[0]}"
                            if (thang[1] != "") || (thang[1] != nil ) || (thang[1] != "nil" )
                                break
                            else
                                return false
                            end
                        end

                        # Last one and still not found? It does not exist, return false.
                        if hash.length == (i + 1)
                            if column[1][:default] != nil
                                # [key, value]
                                default << [column[0], column[1][:default]]
                                break
                            end
                            return false
                        end
                    end
                end
            end
        end

        # Add all the columns that have a default value to the hash
        default.map { |arr| hash[arr[0]] = arr[1] }

        keys = hash.keys.map { |key| key.to_s}
        values = hash.values.map { |value| value.to_s}

        # Create the SQL query
        db.execute("INSERT INTO #{@table_name} (#{keys.join(', ')}) VALUES (#{arr_of_question_marks})", values)

        return true
    end

end