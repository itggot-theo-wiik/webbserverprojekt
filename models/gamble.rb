#Empty line to create pull request
class Gamble

    def self.pay(user_id, money, session)
        db = SQLite3::Database.open('db/db.sqlite')

        if money.to_f < Gamble.balance(session[:id])
            db.execute('INSERT INTO money_history (date, amount, comment, user_id) VALUES (?, ?, ?, ?)', [Time.now.to_s, -money, "pay", session[:id]])
        else
            return false
        end
        
    end

    def self.balance(user_id)
        db = SQLite3::Database.open('db/db.sqlite')

        balance = db.execute('SELECT SUM(amount) FROM money_history WHERE user_id IS ?', user_id).first

        p balance
        
        if balance != [nil]
            return balance.first.to_f
        else
            return 0
        end
    end

    def self.coin_flip(side, bet, session)
        db = SQLite3::Database.open('db/db.sqlite')

        p side
        p bet

        p "OVANFÖR MIG"

        sides = {
            0 => "heads",
            1 => "tails"
        }

        flip = rand(2)
        if sides[flip] == side
            # WIN
            db.execute('INSERT INTO money_history (date, amount, comment, user_id) VALUES (?, ?, ?, ?)', [Time.now, bet * 2, "Casino test", session[:id]])
            # session[:coin] = sides[flip]
            return true
        else
            return false
        end
        
    end
end