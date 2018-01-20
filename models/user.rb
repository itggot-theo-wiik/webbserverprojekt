class User
    def self.create(username, email, password, session)
        db = SQLite3::Database.open('db/db.sqlite')

        # Check if username or email exists
        if db.execute('SELECT * FROM users WHERE username IS ? OR email IS ?', [username, email]) == []
            # Encrypt the password
            password = BCrypt::Password.create(password)

            # Add user
            db.execute('INSERT INTO users (username, email, password) VALUES (?, ?, ?)', [username, email, password])
            User.authenticate(email, password, session)

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

        if encrypted_password != []
            decrypted_password = BCrypt::Password.new(encrypted_password.first.first)
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
            return false
        end
    end
end