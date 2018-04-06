#Empty line to create pull request
class Comment < MyBaseclass

    attr_reader :id, :comment, :user_id, :status, :img_url, :date

    table_name 'comments'
    column 'user_id'
    column 'comment'#, type: String, required: true, unique: true
    column 'img_url'#, type: BCryptHash, required: true
    column 'status', default: "active"
    column 'date'

    def initialize(comment)
        @id = comment[0]
        @comment = comment[1]
        @user_id = comment[2]
        @status = comment[3]
        @img_url = comment[4]
        @date = comment[5]
    end

    #Comment.create({comment: "hej", user_id: 3})
    # def self.create(hash)
    #     db = SQLite3::Database.open('db/db.sqlite')
    #     time = "#{Time.now}"

    #     db.execute("INSERT INTO #{@table_name} (comment, user_id, status, img_url, date) VALUES (?,?,?,?,?)", [comment, user_id.to_i, "active", img_url, time])
    # end

end