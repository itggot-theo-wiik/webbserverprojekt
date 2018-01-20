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
