module MySQL
  module Errors
    class Base < Exception; end
    class Connection < Base; end
    class NotConnected < Base; end
    class NotImplementedType < Base; end
    class MissingParameter < Base; end
    class UnableToFetchLastInsertId < Base; end

    class UnableToRollbackTransaction < Base
      def initialize(@original_error : Exception, @error : Exception)
        super("Unable to rollback")
      end

      def to_s
        "Transaction Error: #{@original_error.inspect},\n Rollback Error: #{@error.inspect}"
      end
    end

    class Query < Base
      def initialize(message, @query : String)
        super(message)
      end

      def to_s
        "Error: #{super},\n Query: #{@query.inspect}"
      end
    end
  end
end
