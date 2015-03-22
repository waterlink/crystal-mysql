class MySQL
  module Errors
    class Base < Exception; end
    class Connection < Base; end
    class NotConnected < Base; end

    class UnableToRollbackTransaction < Base
      def initialize(original_error, error)
        super("Unable to rollback")
        @original_error = original_error
        @error = error
      end

      def to_s
        "Transaction Error: #{@original_error.inspect},\n Rollback Error: #{@error.inspect}"
      end
    end

    class Query < Base
      def initialize(message, query)
        super(message)
        @query = query
      end

      def to_s
        "Error: #{super},\n Query: #{@query.inspect}"
      end
    end
  end
end
