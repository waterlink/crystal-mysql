module MySQL
  module Support
    EMPTY_HANDLE = LibMySQL.init(Pointer(LibMySQL::MySQL).null)

    def self.escape_string(original)
      size = original.size.to_u32

      # According to docs here: https://dev.mysql.com/doc/refman/5.5/en/mysql-real-escape-string.html
      # One would need to allocate at least size*2+1
      escaped = Pointer(UInt8).malloc(size*2+1)

      LibMySQL.escape_string(EMPTY_HANDLE, escaped, original, size)
      String.new(escaped)
    end

    def self.string_from_uint8(chars, len)
      String.new(chars, len)
    end
  end
end
