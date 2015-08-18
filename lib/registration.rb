class Registration
	attr_accessor :id, :course_id, :student_id

  def initialize
    @course_id = course_id
    @student_id = student_id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS registrations
    (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      course_id INTEGER,
      student_id INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS registrations"
    DB[:conn].execute(sql)
  end
end
