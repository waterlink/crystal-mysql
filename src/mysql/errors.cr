class MySQL
  module Errors
    class Error < Exception; end
    class ConnectionError < Error; end
    class NotConnectedError < Error; end
    class ErrorInTransaction < Error; end

    class UnableToRollbackTransactionError < Error
      def initialize(original_error, error)
        super("Unable to rollback")
        @original_error = original_error
        @error = error
      end

      def to_s
        "Transaction Error: #{@original_error.inspect},\n Rollback Error: #{@error.inspect}"
      end
    end

    class QueryError < Error
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
