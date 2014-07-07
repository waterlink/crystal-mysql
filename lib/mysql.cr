require "../ext/mysql"

class MySQL
  def initialize
    @handle = LibMySQL.init(nil)
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
      puts "We're connected!"
    elsif handle.nil?
      puts "Uh-oh. We've got an error somewhere. #{error}"
    else
      puts "WTF? Shouldn't handle.nil? be the only other case? "
    end
  end
end


db = MySQL.new
puts "Got client_info: #{db.client_info}"

db.connect("localhost", # Host
           "root",      # User
           nil,         # Password
           "test",      # Database
           3306_u16,    # Port number
           nil)         # Socket
