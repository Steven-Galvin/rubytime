require_relative './rubytime/version'

# Namespace module for app.
module Rubytime
  # Generic Database Object
  #
  # This actually ended up being a halfway decent little ORM.
  # @TODO: add validation?
  class DBO
    # Instantiates object with database connection and table name.
    #
    # @param table_name [String] The name of the associated database table.
    def initialize(table_name)
      @table = table_name
      @conn = Rubytime::DB
    end

    # Forwards requests to the database
    #
    # This method exists to be stubbed, to isolate this class during testing.
    # @param sql [String] A SQL querystring.
    # @return [PG::Result]
    def exec(sql)
      @conn.exec(sql)
    end

    # Forwards parameterized requests to the database.
    #
    # This method exists to be stubbed, to isolate this class during testing.
    # @param sql [String] A parameterized SQL query.
    # @param params [Array] An array of values to be interpolated.
    # @return [PG::Result]
    def exec_params(sql, params)
      @conn.exec_params(sql, params)
    end

    # Returns an array of symbols representing the tables's column names.
    #
    # @note This method caches the result and so will not reflect changes.
    # @return [Array<Symbol>]
    def columns
      @columns ||= exec('select column_name from '\
        "information_schema.columns where table_name='#{@table}';")
                   .values.flatten.map(&:to_sym)
    end

    # Generic finder method for the DBO
    #
    # rubocop:disable MethodLength
    # rubocop:disable AbcSize
    # @@overload where(conditions)
    #   First form: conditions as a key-value pair
    #   @note fields or joins cannot be specified this way
    #   @param conditions [Hash] One or more key-value pairs
    #   @example
    #     "where(id: 1)" #=> sql: 'SELECT * FROM table where id = 1'
    # @@overload where(conditions)
    #   Second form: multidimensional hash
    #   @param conditions [Hash]
    #   @option conditions [Hash] :conditions One or more key-value pairs
    #   @option conditions [Array<Symbol|String>] :fields A list of fields
    #   @option conditions [String|Symbol] :p_include A parent relationship
    #   @option conditions [String|Symbol] :c_include A child relationship
    # @return [PG::Result]
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

    # Helper method for Rubytime::DBO#where
    #
    # @param other [String|Symbol] The parent association to include
    # @return [String, nil]
    def p_include(other)
      other && "LEFT JOIN #{other} AS parent ON ("\
        "#{@table}.#{other.to_s.chop}_id = parent.id) "
    end

    # Helper method for Rubytime::DBO#where
    #
    # @param other [String|Symbol] The child association to include
    # @return [String, nil]
    def c_include(other)
      other && "LEFT JOIN #{other} AS child ON ("\
        "#{@table}.id = child.#{@table.chop}_id) "
    end

    # Helper method for Rubytime::DBO#where
    #
    # Pairs will be joined with ' AND'
    # @param hash [Hash] One or more key-value pairs.
    # @return [String]
    def conditions(hash)
      hash.map { |k, v| "#{k} = '#{v}'" }.join(' AND')
    end

    # Simple find method
    #
    # @param field [String|Symbol] The field to match
    # @param value [#to_s] The value to be matched
    # @return [PG::Result]
    def find_by(field, value)
      sql = "SELECT * FROM #{@table} WHERE #{field} = '#{value}';"
      exec(sql)
    end

    # Retrieves all associated rows
    #
    # @return [PG::Result]
    def all
      exec("SELECT * FROM #{@table};")
    end

    # Saves objects to the database
    #
    # Does not save unless the column is present in the database.
    # Note that the database columns are cached
    # @param args [Hash] A set of key-value pairs to insert.
    # @return [PG::Result]
    def save(args)
      savedata = args.select { |k, _| columns.include?(k) }
      savedata[:created] = Time.now if columns.include?(:created)
      nums = 1.upto(savedata.size).map { |i| "$#{i}" }.join(', ')
      sql = "INSERT INTO #{@table} (#{savedata.keys.join(', ')}) "\
      "VALUES (#{nums}) returning id;"
      exec_params(sql, savedata.values)
    end

    # Deletes rows by id
    #
    # @param id [String|Integer] The row id to be deleted
    # @return [PG::Result]
    def delete(id)
      sql = "DELETE FROM #{@table} WHERE id = #{id};"
      exec(sql)
    end

    # Updates the row with the given data
    #
    # @note This does not check to see if the specified columns exist
    # @note Updating multiple rows is not supported
    # @TODO: add check to see if column exists
    # @param id [String|Integer] The row id to be updated
    # @param new_data [Hash] A hash containing key-value pairs to be inserted
    def update(id, new_data)
      new_data[:modified] = Time.now if columns.include?(:modified)
      pairs = new_data.map { |k, v| "#{k} = '#{v}'" }.join(', ')
      sql = "UPDATE #{@table} SET #{pairs} WHERE id = #{id};"
      exec(sql)
    end
  end

  # Class for volunteers table
  class Volunteer < Rubytime::DBO
    # Initializes object with fixed table name
    def initialize
      super('volunteers')
    end
  end

  # class for projects table
  class Project < Rubytime::DBO
    # Initializes object with fixed table name
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
