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

    # Gets and returns a object of a specific row which is selected by 'id' in a specific given '@table_name'.
    #
    # @param id [Integer] An integer declaring which row to get from the database.
    # @params table_name [String] A string declaring which table to search in
    # @return [MyBaseclass] An object of the row
    def self.get(id)
        db = SQLite3::Database.open('db/db.sqlite')
        result = db.execute("SELECT * FROM #{@table_name} WHERE id IS ?", id).first
        return self.new(result)
    end

    def self.all()
    # Gets and returns a list of objects of all rows in a specific given 'database'. With sorting
    #
    # @param table_name [String] A string declaring what database to search in
    # @param sort [String] A string declaring in what order to return the list of objects. "reverse" will return the array in an reversed order, if nothing is given, it will be false
    # @return [Array] A list of objects of all the rows
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
    # Attribute checker thing
    #
    # @param hash [Hash] A hash with the column names
    # @return [Boolean] false if something does not meet up to the requirements. Otherwise a hash with the key default: which contains a list of all the default values. And a key of the hash
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

    # Creates a row in the database 
    #
    # @param hash [hash] A hash with all the column names as keys, where the key is the column name and the value is the value of the column name
    # @return [Boolean] True or False. True if the db creation is successfull and false if not.
        attribute_checker = self.attribute_checker(hash)
        return false if !attribute_checker

        default = attribute_checker[:default]
        hash = attribute_checker[:hash]
        # Add all the columns that have a default value to the hash
        default.map { |arr| hash[arr[0]] = arr[1] }

        keys = hash.keys.map { |key| key.to_s}
        values = hash.values.map { |value| value.to_s}

        # Create the SQL query
        db.execute("INSERT INTO #{@table_name} (#{keys.join(', ')}) VALUES (#{arr_of_question_marks})", values)

        return true
    end

    # Updates a cell in a table
    #
    # @param search_column [String] A string of the name of the column where you are looking for a specific value.
    # @param search_value [String] A string or index declaring what value you are searching for, so you change the correct row
    # @param target_column [String] Which column to change
    # @param value [String] The new value
    # @return [Boolean] True or False. True if the db creation is successfull and false if not.
    def self.update(search_column, search_value, target_column, value)
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute("UPDATE #{@table_name} SET #{target_column} = ? WHERE #{search_column} IS ?", [value, search_value])
    end
end