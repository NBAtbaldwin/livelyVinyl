require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    where_line = []
    params.each do |k, v|
      where_line << "#{k} = \"#{v}\""
    end
    where_line = where_line.join(" AND ")
    # debugger
    q = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    self.parse_all(q)
  end
end

class SQLObject
  extend Searchable
end
