
require "lib_mysql"

class MySQL
  def initialize
    @handle = LibMySQL.init(nil)
  end
end
