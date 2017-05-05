require 'rubytime/version'

# namespace module for app
module Rubytime
  # database access layer
  class DBAL
    def connect; end

    def connected?; end

    def clear_tables; end
  end

  # database object
  class DBO
    def intialize; end

    def where(options = {}); end

    def find_by(field, conditions); end

    def save; end

    def create; end

    def delete; end
  end
end
