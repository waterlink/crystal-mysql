module MySQL
  # MySQL connection class. Allows high-level interaction with mysql
  # through LibMySQL.
  #
  # NOTE:
  # The @handle is totally not threadsafe, because it is stateful. So if
  # concurrency is needed, then each concurrent task should own its own
  # connection.
  class Connection
    struct ValueReader
      property value :: Types::SqlType
      property start

      def initialize(@value, @start)
      end

      def initialize
        @value = ""
        @start = 0
      end
    end

    def initialize
      @handle = LibMySQL.init(nil)
      @connected = false
    end

    def client_info
      String.new LibMySQL.client_info
    end

    def error
      String.new LibMySQL.error(@handle)
    end

    def connect(host, user, pass, db, port, socket, flags = 0_u32)
      handle = LibMySQL.real_connect(@handle, host, user, pass, db, port, socket,
                                     flags)
      if handle == @handle
        @connected = true
      elsif handle.nil?
        raise Errors::Connection.new(error)
      else
        raise Errors::Connection.new("Unreachable code")
      end

      self
    end

    def start_transaction
      query(%{START TRANSACTION})
    end

    def commit_transaction
      query(%{COMMIT})
    end

    def rollback_transaction
      query(%{ROLLBACK})
    end

    def transaction
      start_transaction
      yield
      commit_transaction
    rescue transaction_error
      begin
        rollback_transaction
      rescue rollback_error
        raise Errors::UnableToRollbackTransaction.new(transaction_error, rollback_error)
      end
      raise transaction_error
    end

    def close
      LibMySQL.close(@handle)
      @connected = nil
    end

    # @non-threadsafe!
    def query(query_string)
      unless @connected
        raise Errors::NotConnected.new
      end

      code = LibMySQL.query(@handle, query_string)
      raise Errors::Query.new(error, query_string) if code != 0
      result = LibMySQL.store_result(@handle)
      return nil if result.nil?

      fields = [] of LibMySQL::MySQLField
      while field = LibMySQL.fetch_field(result)
        fields << field.value
      end

      rows = [] of Array(Types::SqlType)
      while row = fetch_row(result, fields)
        rows << row
      end

      # NOTE: Why this happens here:
      # *** Error in `/tmp/crystal-run-spec.CAKQ1K': double free or corruption (out): 0x00000000008fa040 ***
      # NOTE: Probably because if result is already exhausted, it just frees itself
      #       That means, that this thing is only useful for #lazy_query
      #LibMySQL.free_result(result)

      rows
    end

    private def fetch_row(result, fields)
      row = LibMySQL.fetch_row(result)
      return nil if row.nil?

      lengths = lengths_from(result, fields)
      reader = ValueReader.new
      row_list = [] of Types::SqlType
      fields.each_with_index do |field, index|
        reader = fetch_value(field, row, reader, lengths[index])
        row_list << reader.value
      end

      row_list
    end

    private def lengths_from(result, fields)
      _lengths = LibMySQL.fetch_lengths(result)
      lengths = [] of UInt32
      fields.each_with_index do |x, index|
        lengths << _lengths[index * 2]
      end
      lengths
    end

    private def fetch_value(field, source, reader, len)
      value = Support.string_from_uint8(source[0] + reader.start, len)

      lifted = Types::Value.new(value, field).lift

      reader.start += len + lifted.account_for_zero
      reader.value = lifted.parsed
      reader
    end
  end
end
