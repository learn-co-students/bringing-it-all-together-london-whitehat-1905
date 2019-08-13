class Dog
  attr_accessor :name, :breed, :id

  def initialize(**kwargs)
    kwargs.each_pair { |key, val| send("#{key}=", val) }
  end

  def save
    return update if id
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, name, breed)
    entry = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").first
    self.id = entry[0]
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, breed, id)
    self
  end

  def self.create(attributes)
    dog = new(attributes)
    dog.save
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs')
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id).first
    new_from_db(row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).first
    new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    result = DB[:conn].execute("SELECT name, breed, id FROM dogs WHERE name = ? AND breed = ?", name, breed).first
    if result.nil?
      return create(name: name, breed: breed)
    else
      return new(name: name, breed: breed, id: result[2])
    end
  end

  def self.new_from_db(row)
    id, name, breed = row
    new(id: id, name: name, breed: breed)
  end

end