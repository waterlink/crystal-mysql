@[Link("mysqlclient_r")]
lib LibMySQL
  struct MySQL
    # Look inside the file:
    #
    #   /usr/local/include/mysql/mysql.h
    #
    # and you'll find lots of gory details
    # about the struct `st_mysql`.
    #
    # However, it seems that the MySQL C API
    # was designed for you *not* to touch it's
    # internals in any way.
    #
    # In that case, I'm leave the struct blank
    # unless it's otherwise necessary to provide
    # more info.
  end

  struct MySQLRes
    # Empty for the moment
  end

  alias MySQLString = UInt8*
  alias MySQLRow = MySQLString

  struct MySQLField
    name: MySQLString
    org_name: MySQLString
    table: MySQLString
    org_table: MySQLString
    db: MySQLString
    catalog: MySQLString
    def: MySQLString

    length: UInt32
    max_length: UInt32

    name_length: UInt32
    org_name_length: UInt32
    table_length: UInt32
    org_table_length: UInt32
    db_length: UInt32
    catalog_length: UInt32
    def_length: UInt32

    flags: UInt16

    decimals: UInt16

    charsetnr: UInt16
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

  # Returns an array of all MYSQL_FIELD structures for a result
  # set. Each structure provides the field definition for one column
  # of the result set.

  fun fetch_fields = mysql_fetch_fields(mysql_result : MySQLRes*) : MySQLField*

  # Closes a previously opened connection. mysql_close() also deallocates
  # the connection handle pointed to by mysql if the handle was allocated
  # automatically by mysql_init() or mysql_connect().

  fun close         = mysql_close(m : MySQL*) : Void

end
