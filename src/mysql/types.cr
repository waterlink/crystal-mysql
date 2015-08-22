module MySQL
  module Types
    struct Date
      property time

      def initialize(time : Time)
        @time = time.date
      end

      def to_s
        TimeFormat.new("%F").format(time)
      end
    end

    alias SqlType = String|Time|Int32|Int64|Float64|Nil|Date|Bool
    IGNORE_FIELD = LibMySQL::MySQLField.new

    struct Value
      property value
      property field

      def initialize(@value, @field)
        if value.is_a?(String)
          @value = value.gsub(/\0/, "")
        end
      end

      def initialize(@value)
        @field = IGNORE_FIELD
      end

      def account_for_zero
        1
      end

      def parsed
        return nil if value == ""
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
        VALUE_DISPATCH.fetch(field.field_type) { Value }.new(value, field)
      end

      def lift_down
        lift_down_class(value).new(value, field)
      end

      private def lift_down_class(value : Nil) Null end
      private def lift_down_class(value : Bool) Boolean end
      private def lift_down_class(value : Int) Integer end
      private def lift_down_class(value : ::Float) Float end
      private def lift_down_class(value) Value end
    end

    struct Datetime < Value
      def _parsed
        TimeFormat.new("%F %T").parse(value.to_s)
      end
    end

    struct SqlDate < Value
      def _parsed
        TimeFormat.new("%F").parse(value.to_s)
      end
    end

    struct Integer < Value
      def _parsed
        value.to_s.to_i
      end

      def to_mysql
        value.to_s
      end
    end

    struct Float < Value
      def _parsed
        value.to_s.to_f
      end

      def to_mysql
        value.to_s
      end
    end

    struct Bit < Value
      def _parsed
        parsed_value = 0_i64
        value.to_s.each_char do |char|
          parsed_value *= 256
          parsed_value += char.ord
        end
        parsed_value
      end
    end

    struct Boolean < Value
      def to_mysql
        value ? "TRUE" : "FALSE"
      end
    end

    struct Null < Value
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
      LibMySQL::MySQLFieldType::MYSQL_TYPE_TINY => Integer,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_SHORT => Integer,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_LONG => Integer,
      LibMySQL::MySQLFieldType::MYSQL_TYPE_LONGLONG => Integer,
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

      # NULL values
      LibMySQL::MySQLFieldType::MYSQL_TYPE_NULL => Null,
    }
  end
end
