#Empty line to create pull request
class User < MyBaseclass

    attr_reader(:id, :username, :email)
    table_name('users')
    #column('username', String)
    #column('password', BCrypt::Password)

    def initialize(user)
        @id = user.first
        @username = user[1]
        @email = user[2]
    end
  
    # def self.get(id)
    #     db = SQLite3::Database.open('db/db.sqlite')
    #     result = db.execute("SELECT * FROM users WHERE id IS ?", id).first
    #     return self.new(result)
    # end

    # def self.all()
    #     db = SQLite3::Database.open('db/db.sqlite')
    #     users = db.execute('SELECT * FROM users')
    #     output = []
    #     users.each { |x| output << User.new(x) }
    #     return output
    # end

    def self.create(username, email, password, session)
        db = SQLite3::Database.open('db/db.sqlite')

        # Is it BAD!?
        if username.include?(" ") || password.include?(" ")
            return false
        end

        # Check if username or email exists
        if db.execute('SELECT * FROM users WHERE username IS ? OR email IS ?', [username, email]) == []
            # Encrypt the password
            password = BCrypt::Password.create(password)

            # Add user
            db.execute('INSERT INTO users (username, email, password) VALUES (?, ?, ?)', [username, email, password])

            # Authenticate to save cookies
            User.authenticate(email, password, session)

            return true
        else
            return false
        end
    end

    def self.authenticate(email, password, session)
        db = SQLite3::Database.open('db/db.sqlite')
        encrypted_password = db.execute('SELECT password FROM users WHERE email IS ?', email)

        # Is there a password assosciated with the email?
        if encrypted_password != []
            decrypted_password = BCrypt::Password.new(encrypted_password.first.first)

            # IS the password Correct?
            if decrypted_password == password
                # Correct
                puts "The password is correct"

                user = db.execute('SELECT * FROM users WHERE email IS ? AND password IS ?', [email, decrypted_password])
                if user != []
                    session[:id] = user.first.first
                    session[:username] = user.first[1]
                    session[:email] = user.first[2]
                    
                    # Check if admin
                    if user.first[4] == true || user.first[4] == "true"
                        session[:admin] = true
                    end
    
                    return true
                else
                    return false
                end

            else
                # Fail
                return false
            end
        else
            return false
        end
    end

    def self.change_password(user_id, new_password)
       db = SQLite3::Database.open('db/db.sqlite')
       encrypted_password = BCrypt::Password.create(new_password)
       db.execute('UPDATE users SET password = ? WHERE id IS ?', [encrypted_password, user_id])
    end
end