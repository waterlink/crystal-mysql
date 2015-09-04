@[Link("mysqlclient")]
lib LibMySQL
  alias MySQLString = UInt8*
  alias MySQLRow = MySQLString
  alias MySQLULong = UInt64
  alias MySQLUInt = UInt32
  alias MySQL = Void
  alias MySQLRes = Void

  enum MySQLFieldType
    MYSQL_TYPE_DECIMAL
    MYSQL_TYPE_TINY
    MYSQL_TYPE_SHORT
    MYSQL_TYPE_LONG
    MYSQL_TYPE_FLOAT
    MYSQL_TYPE_DOUBLE
    MYSQL_TYPE_NULL
    MYSQL_TYPE_TIMESTAMP
    MYSQL_TYPE_LONGLONG
    MYSQL_TYPE_INT24
    MYSQL_TYPE_DATE
    MYSQL_TYPE_TIME
    MYSQL_TYPE_DATETIME
    MYSQL_TYPE_YEAR
    MYSQL_TYPE_NEWDATE
    MYSQL_TYPE_VARCHAR
    MYSQL_TYPE_BIT
    MYSQL_TYPE_NEWDECIMAL=246
    MYSQL_TYPE_ENUM=247
    MYSQL_TYPE_SET=248
    MYSQL_TYPE_TINY_BLOB=249
    MYSQL_TYPE_MEDIUM_BLOB=250
    MYSQL_TYPE_LONG_BLOB=251
    MYSQL_TYPE_BLOB=252
    MYSQL_TYPE_VAR_STRING=253
    MYSQL_TYPE_STRING=254
    MYSQL_TYPE_GEOMETRY=255
  end

  enum MySQLOption
    MYSQL_OPT_CONNECT_TIMEOUT
    MYSQL_OPT_COMPRESS
    MYSQL_OPT_NAMED_PIPE
    MYSQL_INIT_COMMAND
    MYSQL_READ_DEFAULT_FILE
    MYSQL_READ_DEFAULT_GROUP
    MYSQL_SET_CHARSET_DIR
    MYSQL_SET_CHARSET_NAME
    MYSQL_OPT_LOCAL_INFILE
    MYSQL_OPT_PROTOCOL
    MYSQL_SHARED_MEMORY_BASE_NAME
    MYSQL_OPT_READ_TIMEOUT
    MYSQL_OPT_WRITE_TIMEOUT
    MYSQL_OPT_USE_RESULT
    MYSQL_OPT_USE_REMOTE_CONNECTION
    MYSQL_OPT_USE_EMBEDDED_CONNECTION
    MYSQL_OPT_GUESS_CONNECTION
    MYSQL_SET_CLIENT_IP
    MYSQL_SECURE_AUTH
    MYSQL_REPORT_DATA_TRUNCATION
    MYSQL_OPT_RECONNECT
    MYSQL_OPT_SSL_VERIFY_SERVER_CERT
    MYSQL_PLUGIN_DIR
    MYSQL_DEFAULT_AUTH
    MYSQL_ENABLE_CLEARTEXT_PLUGIN
  end

  struct MySQLField
    name: MySQLString
    org_name: MySQLString
    table: MySQLString
    org_table: MySQLString
    db: MySQLString
    catalog: MySQLString
    def: MySQLString

    length: MySQLULong
    max_length: MySQLULong

    name_length: MySQLUInt
    org_name_length: MySQLUInt
    table_length: MySQLUInt
    org_table_length: MySQLUInt
    db_length: MySQLUInt
    catalog_length: MySQLUInt
    def_length: MySQLUInt

    flags: MySQLUInt

    decimals: MySQLUInt

    charsetnr: MySQLUInt

    field_type: MySQLFieldType

    extension: Void*
  end

  # Allocates or initializes a MYSQL object suitable for mysql_real_connect().
  #
  # If the first parameter is a NULL pointer, the function allocates,
  # initializes, and returns a new object.
  #
  # Otherwise, the object is initialized and the address of the object is returned.
  # If mysql_init() allocates a new object, it is freed when mysql_close() is
  # called to close the connection.

  fun init          = mysql_init(m : MySQL*) : MySQL*

  # Provides the ability to set MySQL options.
  #
  # Arguments:
  #
  # * mysql_option The list of options is an Enumerable LibMySQL::MySQLOption.
  # * value - A String that represents tye value of the option.
  
  fun options       = mysql_options(mysql        : MySQL*,  
                                    mysql_option : MySQLOption,
                                    value        : Void*) : Int32

  # mysql_real_connect() attempts to establish a connection to a MySQL database
  # engine running on host. mysql_real_connect() must complete successfully before
  # you can execute any other API functions that require a valid MYSQL connection
  # handle structure.
  #
  # Arguments:
  #
  # * db is the database name. If db is not NULL, the connection sets the default
  # database to this value.
  # * If port is not 0, the value is used as the port number for the TCP/IP
  # connection. Note that the host parameter determines the type of the connection.
  # * If unix_socket is not NULL, the string specifies the socket or named pipe to
  # use. Note that the host parameter determines the type of the connection.
  # * The value of client_flag is usually 0, but can be set to a combination of the
  # following flags to enable certain features.

  fun real_connect  = mysql_real_connect(mysql       : MySQL*,
                                         host        : UInt8*,
                                         user        : UInt8*,
                                         passwd      : UInt8*,
                                         db          : UInt8*,
                                         port        : UInt16,
                                         unix_socket : UInt8*,
                                         client_flag : UInt32) : MySQL*


  # Returns a string that represents the MySQL client library version;
  # for example, "5.0.96".

  fun client_info   = mysql_get_client_info() : UInt8*


  # For the connection specified by mysql, mysql_error() returns a null-terminated
  # string containing the error message for the most recently invoked API function
  # that failed. If a function did not fail, the return value of mysql_error() may
  # be the previous error or an empty string to indicate no error.

  fun error         = mysql_error(mysql : MySQL*) : UInt8*

  # This function is used to create a legal SQL string that you can use in an SQL
  # statement.

  fun escape_string = mysql_real_escape_string(mysql  : MySQL*,
                                               to     : UInt8*,
                                               from   : UInt8*,
                                               length : UInt32)

  # Executes the SQL statement pointed to by the null-terminated string stmt_str.
  # Normally, the string must consist of a single SQL statement without a
  # terminating semicolon (“;”) or \g. If multiple-statement execution has been
  # enabled, the string can contain several statements separated by semicolons.
  # Return Values
  # Zero for success. Nonzero if an error occurred.

  fun query         = mysql_query(mysql : MySQL*, stmt_str : UInt8*) : Int16

  # After invoking mysql_query() or mysql_real_query(), you must call
  # mysql_store_result() or mysql_use_result() for every statement
  # that successfully produces a result set (SELECT, SHOW, DESCRIBE,
  # EXPLAIN, CHECK TABLE, and so forth). You must also call
  # mysql_free_result() after you are done with the result set.
  # Return Values
  # A MYSQL_RES result structure with the results. NULL (0) if an error occurred.

  fun store_result = mysql_store_result(mysql : MySQL*) : MySQLRes*

  # Returns the value generated for an AUTO_INCREMENT column by the previous
  # INSERT or UPDATE statement. Use this function after you have performed an
  # INSERT statement into a table that contains an AUTO_INCREMENT field, or
  # have used INSERT or UPDATE to set a column value with
  # LAST_INSERT_ID(expr).

  fun insert_id = mysql_insert_id(mysql : MySQL*) : MySQLULong

  # Retrieves the next row of a result set. When used after
  # mysql_store_result(), mysql_fetch_row() returns NULL when there
  # are no more rows to retrieve. When used after mysql_use_result(),
  # mysql_fetch_row() returns NULL when there are no more rows to
  # retrieve or if an error occurred.
  # Return values
  # A MYSQL_ROW structure for the next row. NULL if there are no more
  # rows to retrieve or if an error occurred.

  fun fetch_row = mysql_fetch_row(mysql_result : MySQLRes*) : MySQLRow*

  # Returns the number of columns in a result set.

  fun num_fields = mysql_num_fields(mysql_result : MySQLRes*) : UInt16

  # Returns the lengths of the columns of the current row within a
  # result set. If you plan to copy field values, this length
  # information is also useful for optimization, because you can avoid
  # calling strlen(). In addition, if the result set contains binary
  # data, you must use this function to determine the size of the
  # data, because strlen() returns incorrect results for any field
  # containing null characters.

  fun fetch_lengths = mysql_fetch_lengths(mysql_result : MySQLRes*) : UInt32*

  # Returns the definition of one column of a result set as a
  # MYSQL_FIELD structure. Call this function repeatedly to retrieve
  # information about all columns in the result
  # set. mysql_fetch_field() returns NULL when no more fields are
  # left.

  fun fetch_field = mysql_fetch_field(mysql_result : MySQLRes*) : MySQLField*

  # Returns an array of all MYSQL_FIELD structures for a result
  # set. Each structure provides the field definition for one column
  # of the result set.

  fun fetch_fields = mysql_fetch_fields(mysql_result : MySQLRes*) : MySQLField*

  # Frees the memory allocated for a result set by
  # mysql_store_result(), mysql_use_result(), mysql_list_dbs(), and so
  # forth. When you are done with a result set, you must free the
  # memory it uses by calling mysql_free_result().
  # Do not attempt to access a result set after freeing it.

  fun free_result = mysql_free_result(mysql_result : MySQLRes*)

  # Closes a previously opened connection. mysql_close() also deallocates
  # the connection handle pointed to by mysql if the handle was allocated
  # automatically by mysql_init() or mysql_connect().

  fun close         = mysql_close(m : MySQL*) : Void

end
