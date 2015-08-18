require 'pry'

class Course
  attr_accessor :id, :name, :department_id, :department

  # def initialize
  #   @id = id
  #   @name = name
  #   @department_id = department_id
  # end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS courses
    (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      department_id INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS courses"
    DB[:conn].execute(sql)
  end

  def insert
    sql = <<-SQL
      INSERT INTO courses
      (name,department_id)
      VALUES
      (?,?)
    SQL
    DB[:conn].execute(sql, name, department_id)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM courses")[0][0]
  end

  def self.new_from_db(row)
    self.new.tap do |s|
      s.id = row[0]
      s.name =  row[1]
      s.department_id =  row[2]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM courses
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_all_by_department_id(department_id)
    sql = <<-SQL
      SELECT *
      FROM courses
      WHERE department_id = ?
    SQL

    results = DB[:conn].execute(sql, department_id)
    results.map { |row| self.new_from_db(row) }
  end

  def update
    sql = <<-SQL
      UPDATE courses
      SET name = ?,department_id = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, department_id, id)
  end

  def persisted?
    !!id
  end

  def save
    if persisted?
      update
    else
      insert
    end
  end

  def department=(department)
    self.department_id = department.id
    @department = department
    self.save
  end

  def department
    unless @department
      @department = Department.find_by_id(@department_id)
    else
      @department
    end
  end

  def students
    sql = <<-SQL
    SELECT students.*
    FROM students
    JOIN registrations
    ON students.id = registrations.student_id
    JOIN courses
    ON courses.id = registrations.course_id
    WHERE courses.id = ?
    SQL
    result = DB[:conn].execute(sql, self.id)
    result.map do |row|
      Course.new_from_db(row)
    end
  end

  def add_student(student)
    sql = "INSERT INTO registrations (course_id, student_id) VALUES (?,?);"
    DB[:conn].execute(sql, student.id, self.id)
  end
end
