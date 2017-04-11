require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  attr_accessor :title, :body, :users_id
  attr_reader :id


  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @users_id = options['users_id']
  end

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil unless question.length > 0

    Question.new(question.first)
  end

  def self.find_by_author_id(users_id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, users_id)
      SELECT
        *
      FROM
        questions
      WHERE
        users_id = ?
    SQL
    return nil unless question.length > 0

    question.map {|q| Question.new(q) }
  end

  def author
    @users_id
    # should this return their name?
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end
  #
  # def create
  #   raise "#{self} already in database" if @id
  #   PlayDBConnection.instance.execute(<<-SQL, @title, @year, @playwright_id)
  #     INSERT INTO
  #       plays (title, year, playwright_id)
  #     VALUES
  #       (?, ?, ?)
  #   SQL
  #   @id = PlayDBConnection.instance.last_insert_row_id
  # end
  #
  # def update
  #   raise "#{self} not in database" unless @id
  #   PlayDBConnection.instance.execute(<<-SQL, @title, @year, @playwright_id, @id)
  #     UPDATE
  #       plays
  #     SET
  #       title = ?, year = ?, playwright_id = ?
  #     WHERE
  #       id = ?
  #   SQL
  # end
end




class User
  attr_accessor :fname, :lname
  attr_reader :id


  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    user = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless user.length > 0

    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless user.length > 0

    User.new(user.first)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end


  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end
end


class Reply
  attr_accessor :questions_id, :parent_id, :users_id, :body
  attr_reader :id


  def initialize(options)
    @id = options['id']
    @questions_id = options['questions_id']
    @parent_id = options['parent_id']
    @users_id = options['users_id']
    @body = options['body']
  end

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_user_id(users_id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, users_id)
      SELECT
        *
      FROM
        replies
      WHERE
        users_id = ?
    SQL
    return nil unless reply.length > 0

    reply.map {|r| Reply.new(r) }
  end

  def self.find_by_question_id(questions_id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, questions_id)
      SELECT
        *
      FROM
        replies
      WHERE
        questions_id = ?
    SQL
    return nil unless reply.length > 0

    reply.map {|r| Reply.new(r) }
  end

  def author
    User.find_by_id(@users_id)
    #return name?
  end

  def question
    Question.find_by_id(@questions_id)
    #return question text?
  end

  def parent_reply
    Reply.find_by_user_id(@parent_id)
  end

  def child_replies
    Reply.find_by_question_id(@questions_id).select do |chil|
      chil.parent_id = @id
    end
  end
end

class QuestionLike
  attr_reader :questions_id, :users_id


  def initialize(options)
    @questions_id = options['questions_is']
    @users_id = options['users_id']
  end

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.find_by_question_id(question_id)
    question_like = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL
    return nil unless question_like.length > 0

    QuestionLike.new(question_like.first)
  end

  # def find_by_user_id
end


class  QuestionFollow
  attr_reader :questions_id, :users_id, :id


  def initialize(options)
    @id = options['id']
    @questions_id = options['questions_id']
    @users_id = options['users_id']
  end

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.find_by_question_id(questions_id)
    question_follow = QuestionsDBConnection.instance.execute(<<-SQL, questions_id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        questions_id = ?
    SQL
    return nil unless question_follow.length > 0

    question_follow.map { |x| QuestionFollow.new(x) }
  end

  def self.find_by_user_id(users_id)
    question_follow = QuestionsDBConnection.instance.execute(<<-SQL, users_id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        users_id = ?
    SQL
    return nil unless question_follow.length > 0

    question_follow.map { |x| QuestionFollow.new(x) }
  end


  # RETURNS array of User objects
  def self.followers_for_question_id(questions_id)
    followers_for_question = QuestionsDBConnection.instance.execute(<<-SQL, questions_id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        users ON users.id = users_id
      WHERE
        question_follows.questions_id = ?
    SQL
    return nil unless followers_for_question.length > 0

    followers_for_question.map { |x| User.new(x) }
  end

  # returns array of question objects
  def self.followed_questions_for_user_id(users_id)
    questions_followed_by_user = QuestionsDBConnection.instance.execute(<<-SQL, users_id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        questions ON questions.id = questions_id
      WHERE
        question_follows.users_id = ?
    SQL
    return nil unless questions_followed_by_user.length > 0

    questions_followed_by_user.map { |x| Question.new(x) }
  end

end
