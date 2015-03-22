require "./mysql/*"

module MySQL
  def self.connect(*args)
    Connection.new.connect(*args)
  end
end
