require "./mysql/*"

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

  def query(query_string)
    unless @connected
      raise NotConnectedError.new
    end

    LibMySQL.query(@handle, query_string)
  end
end
