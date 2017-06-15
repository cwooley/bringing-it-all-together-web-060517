require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(attr_hash)
    @name = attr_hash[:name]
    @breed = attr_hash[:breed]
    @id = attr_hash[:id]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.all
    get_all = "SELECT * FROM dogs"
    master_arr = DB[:conn].execute(get_all)

    master_arr.map do |student_arr|
      binding.pry
      Dog.new_from_db(student_arr)
    end
  end

  def self.new_from_db(row)
  ### NEED TO FIGURE OUT HOW TO GET ROW ARR TO HASH FOR initialize ARGS
    attr_hash = {}
    attr_hash[:id]= row[0]
    attr_hash[:name] = row[1]
    attr_hash[:breed] = row[2]
    dog = Dog.new(attr_hash)
  end

  def self.create(attr_hash)
    dog = Dog.new(attr_hash)
    dog.save
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (? , ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
    end
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.find_by_name(name)
    ##find dog by name
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    ##find dog by id
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(attr_hash)
    passed_dog = Dog.new(attr_hash)
    if Dog.find_by_name(passed_dog.name) && passed_dog.breed == Dog.find_by_name(passed_dog.name).breed
      return_dog = Dog.find_by_name(passed_dog.name)
    else
      return_dog = Dog.create(attr_hash)
    end
    return_dog
  end

end
