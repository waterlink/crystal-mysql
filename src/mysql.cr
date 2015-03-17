require "./mysql/*"

# MySQL connection class. Allows high-level interaction with mysql
# through LibMySQL.
#
# NOTE:
# The @handle is totally not threadsafe, because it is stateful. So if
# concurrency is needed, then each concurrent task should own its own
# connection.
class MySQL
  class Error < Exception; end
  class ConnectionError < Error; end
  class NotConnectedError < Error; end

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

  def escape_string(original)
    # NOTE: This is how you create a new pointer!
    new = Pointer(UInt8).malloc(0)
    LibMySQL.escape_string(@handle, new, original, original.length.to_u32)
    String.new(new)
  end

  def connect(host, user, pass, db, port, socket, flags = 0_u32)
    handle = LibMySQL.real_connect(@handle, host, user, pass, db, port, socket,
                                   flags)
    if handle == @handle
      @connected = true
    elsif handle.nil?
      raise ConnectionError.new(error)
    else
      raise ConnectionError.new("Unreachable code")
    end

    self
  end

  # @non-threadsafe!
  def query(query_string)
    unless @connected
      raise NotConnectedError.new
    end

    LibMySQL.query(@handle, query_string)
    result = LibMySQL.store_result(@handle)
    num_fields = LibMySQL.num_fields(result)

    rows = Array.new(1, fetch_row(result, num_fields))
    rows
  end

  private def fetch_row(result, num_fields)
    row = LibMySQL.fetch_row(result)
    fields = LibMySQL.fetch_fields(result)

    full_len = 0
    (0_u16...num_fields).map do |index|
      len = fields[index].length
      value = string_from_uint8(row[0] + full_len, len)
      full_len += len
      value
    end
  end

  private def string_from_uint8(s, len)
    (0_u32...len).inject("") { |acc, i| acc + s[i].chr }
  end
end
