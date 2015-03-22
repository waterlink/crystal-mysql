class MySQL
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
  end
end
