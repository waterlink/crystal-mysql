require "./mysql/*"

class MySQL
  class ConnectionError < StandardError; end

  def initialize
    @handle = LibMySQL.init(nil)
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
      true
    elsif handle.nil?
      raise ConnectionError.new(error)
    else
      raise ConnectionError.new("Unreachable code")
    end
  end
end
