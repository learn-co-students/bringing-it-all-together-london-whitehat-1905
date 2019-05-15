class Dog

  attr_accessor :name
  attr_reader :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    dog = Dog.new(name: @name, breed: @breed, id: @id)
    dog
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map{|dog| self.new(name: dog[1], breed: dog[2], id: dog[0])}.first
  end

  def self.find_or_create_by(name: name, breed: breed)

    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      SQL

    result = DB[:conn].execute(sql, name, breed)

    if result.empty?
      newdog = self.create(name: name, breed: breed)
    else
      id, name, breed = result.first
      newdog = self.new(name: name, breed: breed, id: id)
    end

    newdog

  end

  def self.new_from_db(row)
    id, name, breed = row
    dog = self.new(name: name, breed: breed, id: id)
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      SQL

    result = DB[:conn].execute(sql, name).map{|dog| self.new_from_db(dog)}
    result[0]
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?
      WHERE id = ?
      SQL

    result = DB[:conn].execute(sql, @name, @id).first

  end

end
