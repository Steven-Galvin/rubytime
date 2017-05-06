require_relative './rubytime/version'

# namespace module for app
module Rubytime
  # database object
  class DBO
    def initialize(table_name)
      @table = table_name
      @conn = Rubytime::DB
    end

    def exec(sql)
      @conn.exec(sql)
    end

    def exec_params(sql, params)
      @conn.exec_params(sql, params)
    end

    def columns
      @columns ||= exec('select column_name from '\
        "information_schema.columns where table_name='#{@table}';")
                   .values.flatten.map(&:to_sym)
    end

    # rubocop:disable MethodLength
    # rubocop:disable AbcSize
    def where(conditions = {})
      options = {
        conditions: conditions,
        fields: ['*']
      }
      if conditions.key?(:conditions)
        options = {
          conditions: {},
          fields: ['*']
        }.merge(conditions)
      end
      fields = options[:fields].join(', ')
      sql = "SELECT #{fields} FROM #{@table} "
      sql << p_include(options[:p_include]).to_s
      sql << c_include(options[:c_include]).to_s
      unless options[:conditions].empty?
        sql << 'WHERE ' + conditions(options[:conditions]).to_s
      end
      exec(sql.rstrip + ';')
    end

    def p_include(other)
      other && "LEFT JOIN #{other} AS parent ON ("\
        "#{@table}.#{other.to_s.chop}_id = parent.id) "
    end

    def c_include(other)
      other && "LEFT JOIN #{other} AS child ON ("\
        "#{@table}.id = child.#{@table.chop}_id) "
    end

    def conditions(hash)
      hash.map { |k, v| "#{k} = '#{v}'" }.join(' AND')
    end

    def find_by(field, value)
      sql = "SELECT * FROM #{@table} WHERE #{field} = '#{value}';"
      exec(sql)
    end

    def all
      exec("SELECT * FROM #{@table};")
    end

    def save(args)
      savedata = args.select { |k, _| columns.include?(k) }
      savedata[:created] = Time.now if columns.include?(:created)
      nums = 1.upto(savedata.size).map { |i| "$#{i}" }.join(', ')
      sql = "INSERT INTO #{@table} (#{savedata.keys.join(', ')}) "\
      "VALUES (#{nums}) returning id;"
      exec_params(sql, savedata.values)
    end

    def delete(id)
      sql = "DELETE FROM #{@table} WHERE id = #{id};"
      exec(sql)
    end

    def update(id, new_data)
      new_data[:modified] = Time.now if columns.include?(:modified)
      pairs = new_data.map { |k, v| "#{k} = '#{v}'" }.join(', ')
      sql = "UPDATE #{@table} SET #{pairs} WHERE id = #{id};"
      exec(sql)
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
