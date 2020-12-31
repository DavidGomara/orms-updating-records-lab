require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade 
    @id = id
  end 

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    );
    SQL

    DB[:conn].execute(sql)
  end 

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students;
    SQL

    DB[:conn].execute(sql)
  end 

  def save
    sql = <<-SQL 
    INSERT INTO students (name, grade)
    VALUES (?,?)
    SQL

    last_id = <<-SQL
    SELECT id
    FROM students
    ORDER BY id DESC
    LIMIT 1
    SQL

    sql_2 = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id 
    IS ?
    SQL

    if self.id
      DB[:conn].execute(sql_2, self.name, self.grade, self.id)
    else 
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute(last_id)[0][0]
    end 
  end 

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save 
    student
  end 

  def self.new_from_db(row)
    student_id = row[0]
    student_name = row[1]
    student_grade = row [2]
    student = Student.new(student_name, student_grade, student_id)
  end 

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name 
    IS ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
  end 

  def update 
    sql = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id 
    IS ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end 
end
