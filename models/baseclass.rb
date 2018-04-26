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
    def self.attribute_checker(hash)
        db = SQLite3::Database.open('db/db.sqlite')
        
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
                    hash.each_with_index do |hash_column, i|

                        # Empty?
                        if "#{hash_column[0]}" == "#{column[0]}"
                            if (hash_column[1] != "") && (hash_column[1] != nil ) && (hash_column[1] != "nil" )
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

        return {default: default, hash: hash}
        # return default
    end
        # Add all the columns that have a default value to the hash
        default.map { |arr| hash[arr[0]] = arr[1] }

        keys = hash.keys.map { |key| key.to_s}
        values = hash.values.map { |value| value.to_s}

        # Create the SQL query
        db.execute("INSERT INTO #{@table_name} (#{keys.join(', ')}) VALUES (#{arr_of_question_marks})", values)

        return true
    end

    def self.update(search_column, search_value, target_column, value)
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute("UPDATE #{@table_name} SET #{target_column} = ? WHERE #{search_column} IS ?", [value, search_value])
    end
end