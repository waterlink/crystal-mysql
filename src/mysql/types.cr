module MySQL
  module Types
    class Date
      property time

      @time : Time
      def initialize(time : Time)
        @time = time.date
      end

      def to_s
        Time::Format.new("%F").format(time)
      end
    end

    alias SqlType = String|Time|Int32|Int64|Float64|Nil|Date|Bool|Slice(UInt8)

    IGNORE_FIELD_RAW = LibMySQL::MySQLField.new
    IGNORE_FIELD = pointerof(IGNORE_FIELD_RAW)

    class Value
      property value
      property field

      def initialize(@value : SqlType, @field : Pointer(LibMySQL::MySQLField))
      end

      def initialize(@value)
        @field = IGNORE_FIELD
      end

      def account_for_zero
        1
      end

      def parsed
        _parsed
      end

      def _parsed
        value
      end

      def to_mysql
        "'#{Support.escape_string(value.to_s)}'"
      end

      def lift
        return self unless self.is_a?(Value)
        VALUE_DISPATCH.fetch(field.value.field_type) { Value }.new(value, field)
      end

      def lift_down
        lift_down_class(value).new(value, field)
      end

      private def lift_down_class(value : Nil) Null end
      private def lift_down_class(value : Bool) Boolean end
      private def lift_down_class(value : Int) Integer end
      private def lift_down_class(value : ::Float) Float end
      private def lift_down_class(value : Time) Datetime end
      private def lift_down_class(value : Slice(UInt8)) Blob end
      private def lift_down_class(value) Value end
    end

    class Blob < Value
      def _parsed
        value.to_s.to_slice
      end

      def to_mysql
        "'#{String.new(value.as Slice(UInt8))}'"
      end
    end

    class Datetime < Value
      def _parsed
        Time::Format.new("%F %T").parse(value.to_s, Time::Kind::Utc)
      end

      def to_mysql
        %{'#{(value.as Time).to_utc.to_s("%F %T")}'}
      end
    end

    class SqlDate < Value
      def _parsed
        Time::Format.new("%F").parse(value.to_s)
      end
    end

    class Integer < Value
      def _parsed
        value.to_s.to_i
      end

      def to_mysql
        value.to_s
      end
    end

    class BigInteger < Value
      def _parsed
        value.to_s.to_i64
      end

      def to_mysql
        value.to_s
      end
    end

    class Float < Value
      def _parsed
        value.to_s.to_f
      end

      def to_mysql
        value.to_s
      end
    end

    class Bit < Value
      def _parsed
        parsed_value = 0_i64
        value.to_s.each_char do |char|
          parsed_value *= 256
          parsed_value += char.ord
        end
        parsed_value
      end
    end

    class Boolean < Value
      def _parsed
        return true if value == "1"
        false
      end

      def to_mysql
        value ? "TRUE" : "FALSE"
      end
    end

    class Null < Value
      def _parsed
        nil
      end

      def to_mysql
        "NULL"
      end

      def account_for_zero
        0
      end
    end

    VALUE_DISPATCH = {
      # Integer values
      LibMySQL::MySQLFieldType::MYSQL_TYPE_SHORT => Integer,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_LONG => Integer,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_LONGLONG => BigInteger,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_INT24 => Integer,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_YEAR => Integer,

      # Float values
      LibMySQL::MySQLFieldType::MYSQL_TYPE_DECIMAL => Float,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_FLOAT => Float,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_DOUBLE => Float,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_NEWDECIMAL => Float,

      # Date & Time values
      LibMySQL::MySQLFieldType::MYSQL_TYPE_TIMESTAMP => Datetime,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_DATETIME => Datetime,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_DATE => SqlDate,

      # Bit values
      LibMySQL::MySQLFieldType::MYSQL_TYPE_BIT => Bit,

      # Bool values
      LibMySQL::MySQLFieldType::MYSQL_TYPE_TINY => Boolean,

      # NULL values
      LibMySQL::MySQLFieldType::MYSQL_TYPE_NULL => Null,

      # BLOB values
      LibMySQL::MySQLFieldType::MYSQL_TYPE_TINY_BLOB => Blob,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_MEDIUM_BLOB => Blob,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_LONG_BLOB => Blob,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_BLOB => Blob,
    }
  end
end
