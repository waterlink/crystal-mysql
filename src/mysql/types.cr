module MySQL
  module Types
    alias SqlType = String|Time|Int32|Int64|Float64|Nil

    INTEGER_TYPES = [
                     LibMySQL::MySQLFieldType::MYSQL_TYPE_TINY,
                     LibMySQL::MySQLFieldType::MYSQL_TYPE_SHORT,
                     LibMySQL::MySQLFieldType::MYSQL_TYPE_LONG,
                     LibMySQL::MySQLFieldType::MYSQL_TYPE_LONGLONG,
                     LibMySQL::MySQLFieldType::MYSQL_TYPE_INT24,
                     LibMySQL::MySQLFieldType::MYSQL_TYPE_YEAR,
                    ]

    FLOAT_TYPES = [
                   LibMySQL::MySQLFieldType::MYSQL_TYPE_DECIMAL,
                   LibMySQL::MySQLFieldType::MYSQL_TYPE_FLOAT,
                   LibMySQL::MySQLFieldType::MYSQL_TYPE_DOUBLE,
                   LibMySQL::MySQLFieldType::MYSQL_TYPE_NEWDECIMAL,
                  ]

    struct Value
      property value
      property field

      def initialize(@value, @field)
      end

      def account_for_zero
        1
      end

      def parsed
        value
      end

      def lift
        if field.field_type == LibMySQL::MySQLFieldType::MYSQL_TYPE_TIMESTAMP ||
            field.field_type == LibMySQL::MySQLFieldType::MYSQL_TYPE_DATETIME
          return Datetime.new(value, field)
        end

        if field.field_type == LibMySQL::MySQLFieldType::MYSQL_TYPE_DATE && value.is_a?(String)
          return Date.new(value, field)
        end

        if Types::INTEGER_TYPES.includes?(field.field_type)
          return Integer.new(value, field)
        end

        if Types::FLOAT_TYPES.includes?(field.field_type)
          return Float.new(value, field)
        end

        if field.field_type == LibMySQL::MySQLFieldType::MYSQL_TYPE_BIT
          return Bit.new(value, field)
        end

        if field.field_type == LibMySQL::MySQLFieldType::MYSQL_TYPE_NULL
          return Null.new(value, field)
        end

        self
      end
    end

    struct Datetime < Value
      def parsed
        TimeFormat.new("%F %T").parse(value)
      end
    end

    struct Date < Value
      def parsed
        TimeFormat.new("%F").parse(value)
      end
    end

    struct Integer < Value
      def parsed
        value.to_i
      end
    end

    struct Float < Value
      def parsed
        value.to_f
      end
    end

    struct Bit < Value
      def parsed
        parsed_value = 0_i64
        value.each_char do |char|
          parsed_value *= 256
          parsed_value += char.ord
        end
        parsed_value
      end
    end

    struct Null < Value
      def parsed
        nil
      end

      def account_for_zero
        0
      end
    end
  end
end
