require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students  (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end


  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() from students")[0][0]
    end

  end

  def self.create(name:, grade:)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name=?
    SQL

    student = DB[:conn].execute(sql, name).first
    self.new_from_db(student)

  end

  def update
    sql = <<-SQL
      UPDATE students SET name=?, grade=? WHERE id=?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


  def self.find_or_create_by(name:, grade:)
    student = DB[:conn].execute("SELECT * FROM students WHERE name=? AND breed=?", name, breed)
    if (!student.empty?)
      student_data = student[0]
      student =  Student.new(student_data[0], student_data[1], student_data[2])
    else
      student = Student.create(name: name, grade: grade)
    end
    student
end
