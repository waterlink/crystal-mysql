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
  class QueryError < Error; end

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

    code = LibMySQL.query(@handle, query_string)
    raise QueryError.new(error) if code != 0
    result = LibMySQL.store_result(@handle)
    return nil if result.nil?

    fields = [] of LibMySQL::MySQLField
    while field = LibMySQL.fetch_field(result)
      fields << field.value
    end

    rows = [] of Array(String)
    while row = fetch_row(result, fields)
      rows << row
    end

    # NOTE: Why this happens here:
    # *** Error in `/tmp/crystal-run-spec.CAKQ1K': double free or corruption (out): 0x00000000008fa040 ***
    #LibMySQL.free_result(result)

    rows
  end

  def fetch_row(result, fields)
    row = LibMySQL.fetch_row(result)
    return nil if row.nil?

    full_len = 0
    index = 0
    row_list = [] of String
    fields.each do |field|
      len = field.max_length

      value = string_from_uint8(row[0] + full_len, len)
      if value[-1] == '\0'
        value = value[0...-1]
        len -= 1
      end

      full_len += len + 1
      index += 1
      row_list << value
    end

    row_list
  end

  def string_from_uint8(s, len)
    (0_u64...len).inject("") { |acc, i| acc + s[i].chr }
  end
end
