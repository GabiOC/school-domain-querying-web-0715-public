class Department
	attr_accessor :id, :name, :course_id, :course

	def add_course(course)
		course.department_id = self.id
		course.save
		self.save
	end

	def courses
			Course.find_all_by_department_id(@id)
	end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS departments
    (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS departments"
    DB[:conn].execute(sql)
  end

  def insert
    sql = <<-SQL
      INSERT INTO departments
      (name)
      VALUES
      (?)
    SQL
    DB[:conn].execute(sql, name)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM departments")[0][0]
  end

  def self.new_from_db(row)
    self.new.tap do |s|
      s.id = row[0]
      s.name =  row[1]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM departments
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM departments
      WHERE id = ?
    SQL

		DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE departments
      SET name = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, id)
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
end
