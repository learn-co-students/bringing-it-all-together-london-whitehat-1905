class Dog
    attr_accessor :name, :breed
    attr_reader :id
    
    def initialize(args)
        @name = args[:name]
        @breed = args[:breed]
        if args[:id]
            @id = args[:id]
        else
            @id = nil
        end
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY,
                                        name TEXT,
                                        breed TEXT);
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs;"
        DB[:conn].execute(sql)
    end

    def save
        sql = "SELECT * FROM dogs WHERE name = '#{@name}' AND breed = '#{@breed}';"
        if DB[:conn].execute(sql).empty?
            sql = "INSERT INTO dogs (name, breed) VALUES ('#{@name}' , '#{@breed}');"
            DB[:conn].execute(sql)
            sql = "SELECT last_insert_rowid() FROM dogs;"
            set_id(DB[:conn].execute(sql)[0][0])
        end
        return self
    end

    def set_id(int)
        @id = int
    end

    def self.create(hash)
        obj = Dog.new(hash)
        obj.save
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id= #{id};"
        row = DB[:conn].execute(sql)
        obj = Dog.new({:name => row[0][1], :breed => row[0][2], :id => row[0][0]})
        return obj
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}';"
        if !DB[:conn].execute(sql).empty?
            sql = "SELECT id FROM dogs WHERE name = '#{name}' AND breed = '#{breed}';"
            id = DB[:conn].execute(sql)[0][0]
            Dog.create({:name => name, :breed => breed, :id => id})
        else
            obj = Dog.create({:name => name, :breed => breed})
            obj.save
        end
    end        

    def self.new_from_db(row)
        Dog.new({:name => row[1], :breed => row[2], :id => row[0]})
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = '#{name}';"
        row = DB[:conn].execute(sql)
        Dog.new({:name => row[0][1], :breed => row[0][2], :id => row[0][0]})
    end

    def update
        sql = "UPDATE dogs SET id = #{@id}, name = '#{name}', breed = '#{breed}';"
        DB[:conn].execute(sql)
    end


end