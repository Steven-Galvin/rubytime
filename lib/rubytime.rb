require_relative './rubytime/version'

# namespace module for app
module Rubytime
  # database object
  class DBO
    def initialize(table_name)
      @table = table_name
      @conn = ::DB
    end

    def columns
      @columns ||= @conn.exec('select column_name from '\
        "information_schema.columns where table_name='#{@table}';")
                        .values.flatten.map(&:to_sym)
    end

    def where(conditions, options = {})
      sql = "SELECT * FROM #{@table}"
      if options[:include]
        sql += "LEFT JOIN #{options[:include]} AS t2 ON ("\
          "#{@table}.id = t2.#{@table.chop}_id) "
      end
      sql += "WHERE '#{conditions}';"
      @conn.exec(sql)
    end

    def find_by(field, value)
      sql = "SELECT * FROM #{@table} WHERE #{field} = '#{value}';"
      @conn.exec(sql)
    end

    def all
      @conn.exec("SELECT * FROM #{@table};")
    end

    def save(args)
      savedata = args.select { |k, _| columns.include?(k) }
      savedata[:created] = Time.now if columns.include?(:created)
      nums = 1.upto(savedata.size).map { |i| "$#{i}" }.join(', ')
      sql = "INSERT INTO #{@table} (#{savedata.keys.join(', ')}) "\
      "VALUES (#{nums}) returning id;"
      @conn.exec_params(sql, savedata.values)
    end

    def delete(id)
      sql = "DELETE FROM #{@table} WHERE id = #{id}"
      @conn.exec(sql)
    end

    def update(id, new_data)
      sql = "UPDATE #{@table} SET #{new_data} WHERE id = #{id}"
      @conn.exec(sql)
    end
  end

  # Class for volunteers table
  class Volunteer < Rubytime::DBO
    def initialize
      super('volunteers')
    end
  end

  # class for projects table
  class Project < Rubytime::DBO
    def initialize
      super('projects')
    end
  end
end

# Adds a method to the Hash class.
#
# @note We're extending the global object because, hey, if Rails can do it...
class Hash
  # Recursively turns string hash keys to symbols.
  #
  # The key must respond to to_sym. So basically just strings.
  # @return A new hash with symbols instead of string keys.
  def symbolize
    # changing this to use responds_to? because it's more Ruby-ish
    # in Smalltalk-influenced OO languages method calls simply send a message
    # to the object the method is being called on
    # the idea of 'duck typing' is that we don't care if it *is* a duck
    # we just care if it quacks like one
    Hash[map { |k, v| [k.to_sym, v.respond_to?(:symbolize) ? v.symbolize : v] }]
  end
end
