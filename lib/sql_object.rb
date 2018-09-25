require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject

  def initialize(params = {})
    params.each do |att, val|
      col = att.to_sym
      raise "unknown attribute '#{col}'" unless self.class.columns.include?(col)
      self.send("#{att}=", val)
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self.to_s.downcase}s"
  end

  def self.columns
    return @columns if @columns
    @columns = []
    query ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        1
    SQL

    query[0].each do |k|
      @columns << k.to_sym
    end
    @columns
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        @attributes[col]
      end
      define_method("#{col}=") do |arg|
        self.attributes[col] = arg
      end
    end
  end

  def self.all
    all_query = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    self.parse_all(all_query)
  end

  def self.parse_all(results)
    results.map { |datum| self.new(datum) }
  end

  def self.find(id)
    id_query = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
    self.parse_all(id_query).first
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    q_marks = (['?'] * (self.class.columns.length-1)).join(',')
    cols = self.class.columns.drop(1).map(&:to_s).join(',')
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{cols})
      VALUES
        (#{q_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_string = self.class.columns.drop(1).map do |col|
      col.to_s+" = ?"
    end
    set_string = set_string.join(', ')
    updates = attribute_values.drop(1)
    DBConnection.execute(<<-SQL, *updates, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_string}
      WHERE
        id = ?
    SQL
  end

  def save
    begin
      self.update unless self.id.nil?
    rescue
      self.insert
    end
  end

end
