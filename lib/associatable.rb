require_relative 'searchable'
require 'active_support/inflector'
require_relative 'db_connection'


class AssocOptions

  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] || (name.to_s+"_id").to_sym
    @class_name = options[:class_name] || (name.to_s).camelcase.singularize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] || ((self_class_name.to_s+"_id").downcase).to_sym
    @class_name = options[:class_name] || (name.to_s).camelcase.singularize
  end
end

module Associatable

  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      assoc_options = self.class.assoc_options[name]
      f_key = self.send(assoc_options.foreign_key)
      id = assoc_options.primary_key
      m_class = assoc_options.model_class
      m_class.where({id: f_key}).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      assoc_options = self.class.assoc_options[name]
      f_key = assoc_options.foreign_key
      id = self.send(assoc_options.primary_key)
      m_class = assoc_options.model_class
      m_class.where({f_key => id})
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]
      join_field = "#{through_options.table_name}.#{source_options.foreign_key} = #{source_options.table_name}.id"
      where_field = "#{through_options.table_name}.id"
      id = self.send(through_options.foreign_key)

      query = DBConnection.execute(<<-SQL, id)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{through_options.table_name}
        JOIN
          #{source_options.table_name} ON #{join_field}
        WHERE
          #{where_field} = ?
      SQL
      source_options.model_class.new(query[0])
    end

  end
end

class SQLObject
  extend Associatable
end
