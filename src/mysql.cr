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

    rows = Array.new(1, fetch_row(result))
    while row = fetch_row(result)
      rows << row
    end

    # NOTE: Why this happens here:
    # *** Error in `/tmp/crystal-run-spec.CAKQ1K': double free or corruption (out): 0x00000000008fa040 ***
    #LibMySQL.free_result(result)

    rows
  end

  private def fetch_row(result)
    row = LibMySQL.fetch_row(result)
    return nil if row.nil?

    fields = LibMySQL.fetch_fields(result)

    full_len = 0
    index = 0
    row_list :: Array(String)
    while !(field = LibMySQL.fetch_field(result)).nil?
      len = field[0].length
      value = string_from_uint8(row[0] + full_len, len)
      full_len += len + 1
      index += 1
      row_list << value
    end
    row_list
  end

  private def string_from_uint8(s, len)
    (0_u32...len).inject("") { |acc, i| acc + s[i].chr }
  end
end
